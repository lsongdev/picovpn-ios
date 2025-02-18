import Xray
import SwiftUI
import SwiftUIX

struct DatasetRowView: View {
    @ObservedObject var dataset: Dataset
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(dataset.name)
            }
            
            Spacer()
            
            if dataset.isDownloading {
                ProgressView().progressViewStyle(.circular)
            }
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
        .contextMenu {
            Button {
                Task {
                    await dataset.download()
                }
            } label: {
                Label("Update", systemImage: "arrow.clockwise")
            }
            
            Button(role: .destructive) {
                try? dataset.delete()
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}

struct DatasetsView: View {
    @StateObject private var datasetsManager = DatasetsManager()
    @State private var showingAddSheet = false
    
    var body: some View {
        List {
            ForEach(datasetsManager.datasets) { dataset in
                DatasetRow(dataset: dataset)
            }
            .onDelete { index in
                datasetsManager.datasets.remove(atOffsets: index)
                datasetsManager.saveDatasets()
            }
            
            Section {
                Button(action: {
                    Task {
                        await datasetsManager.updateAllDatasets()
                    }
                }) {
                    HStack {
                        Text("Update all datasets")
                        Spacer()
                        Image(systemName: "arrow.clockwise")
                    }
                }
                
                Button(action: datasetsManager.deleteAllFiles) {
                    HStack {
                        Text("Delete all files")
                        Spacer()
                        Image(systemName: "trash")
                    }
                }
                .foregroundColor(.red)
            }
        }
        .sheet(isPresented: $showingAddSheet) {
            AddDatasetView(
                onSave: { dataset in
                    datasetsManager.datasets.append(dataset)
                    datasetsManager.saveDatasets()
                }
            )
        }
        .navigationBarTitle("Datasets")
        .presentationDetents([.large])
        .toolbar {
            Button(action: { showingAddSheet = true }) {
                Image(systemName: "plus")
            }
        }
    }
}

struct DatasetRow: View {
    @ObservedObject var dataset: Dataset
    
    var body: some View {
        Group {
            if dataset.isDownloaded {
                NavigationLink(destination: DatasetView(dataset: dataset)) {
                    DatasetRowView(dataset: dataset)
                }
            } else {
                DatasetRowView(dataset: dataset)
                    .onTapGesture {
                        Task {
                            await dataset.download()
                        }
                    }
            }
        }
    }
}

struct DatasetView: View {
    var dataset: Dataset
    @State var geodata: GeoData = GeoData()
    @State var searchText: String = ""
    
    // Filtered servers based on search text
    private var filteredItems: [GeoDataRow] {
        if searchText.isEmpty {
            return geodata.codes
        }
        return geodata.codes.filter { code in
            code.code.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        List {
            Section {
                HStack {
                    Text("Name")
                    Spacer()
                    Text(dataset.name)
                }
            }
            
            Section {
                HStack {
                    Text("Category Count")
                    Spacer()
                    Text("\(geodata.categoryCount)")
                }
                HStack {
                    Text("Rule Count")
                    Spacer()
                    Text("\(geodata.ruleCount)")
                }
            }
            ForEach(filteredItems.indices, id: \.self) { index in
                HStack () {
                    Text(filteredItems[index].code)
                    Spacer()
                    Text("\(filteredItems[index].ruleCount)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            if filteredItems.isEmpty {
                Text("No items.")
                    .foregroundColor(.secondary)
            }
        }
        .navigationTitle(dataset.name)
        .searchable(text: $searchText)
        .onAppear {
            Task {
                let res = XrayLoadGeoData(dataset.filePath.path, dataset.type)
                self.geodata = try JSONDecoder().decode(GeoData.self, from: res.data(using: .utf8)!)
            }
        }
    }
}

// MARK: - Views
struct AddDatasetView: View {
    @Environment(\.dismiss) private var dismiss
    @State var name: String = ""
    @State var type: String = "ip"
    @State var url : String = ""
    
    var onSave: (Dataset) -> Void = { _ in }
    
    var body: some View {
        NavigationView {
            List {
                InputField("Name", text: $name, placeholder: "dataset name")
                Picker("Type", selection: $type) {
                    Text("IP").tag("ip")
                    Text("Domain").tag("domain")
                }
                InputField("URL", text: $url, placeholder: "https://")
            }
            .navigationTitle("Add Dataset")
            .navigationBarItems(
                leading: Button("Cancel") { dismiss() },
                trailing: Button("Add") {
                    onSave(Dataset(type: type, name: name, url: url))
                    dismiss()
                }
                .disabled(name.isEmpty || url.isEmpty)
            )
            .navigationBarTitle("Add Dataset", displayMode: .inline)
            .presentationDetents([.medium])
        }
       
    }
}
