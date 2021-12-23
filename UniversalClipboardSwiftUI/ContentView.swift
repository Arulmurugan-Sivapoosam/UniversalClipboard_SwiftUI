//
//  ContentView.swift
//  UniversalClipboardSwiftUI
//
//

import SwiftUI

struct ContentView: View {
  
  @State var attachments: [Attachment]
  @State private var isPresented: Bool = false
  @State private var selectedAttachment: Attachment?
  
  var body: some View {
    NavigationView {
      List {
        ForEach(attachments, id: \.self) { attachment in
          HStack {
            getImage(from: attachment)
              .resizable()
              .aspectRatio(contentMode: .fit)
              .padding(10)
              .frame(width: 70, height: 70, alignment: .leading)
            VStack {
              hText(with: attachment.name)
              hText(with: attachment.size)
            }
          }
          .onTapGesture(perform: {
            selectedAttachment = attachment
          })
          .sheet(item: $selectedAttachment, onDismiss: nil) { item in
            AttachmentPreview(isPresented: isPresented, attachments: attachments, selectedAttachment: attachment)
          }
        }
        .onDelete { index in
          attachments.remove(atOffsets: index)
        }
      }
      .navigationTitle("Attachments")
      .toolbar {
        Button {
          pasteAction()
        } label: {
          Image(systemName: "doc.on.clipboard")
            .imageScale(.medium)
        }
      }
    }
  }
  
  private func getImage(from attachment: Attachment) -> Image {
    let attachmentThumbNail = UIImage(data: attachment.data)
    return (attachmentThumbNail == nil ? Image(systemName: "doc") : Image(uiImage: attachmentThumbNail!))
  }
  
  private func hText(with content: String) -> some View {
    HStack {
      Text(content)
        .lineLimit(1)
      Spacer()
    }
  }
  
  private func pasteAction() {
    for itemProvider in UIPasteboard.general.itemProviders {
      guard let item = itemProvider.copy() as? NSItemProvider,
            let attachmentName = item.suggestedName,
            let uti = item.registeredTypeIdentifiers.first else {break}
      item.loadDataRepresentation(forTypeIdentifier: uti) { data, error in
        if let data = data {
          DispatchQueue.main.async {
            self.attachments.insert(.init(id: attachmentName, name: attachmentName, data: data), at: .zero)
          }
        }
      }
    }
  }
  
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView(attachments: [])
  }
}

class Attachment: NSObject, Identifiable {
  var id: String
  var name: String
  var size: String { getSizeInMB() }
  var data: Data
  
  internal init(id: String, name: String, data: Data) {
    self.id = id
    self.name = name
    self.data = data
  }
  
  func getSizeInMB() -> String {
    let bcf = ByteCountFormatter()
    bcf.allowedUnits = [.useMB]
    bcf.countStyle = .file
    return bcf.string(fromByteCount: Int64(data.count)).replacingOccurrences(of: ",", with: ".")
  }
  
}
