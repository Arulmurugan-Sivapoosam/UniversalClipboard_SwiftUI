//
//  AttachmentPreview.swift
//  UniversalClipboardSwiftUI
//
//  Created by arul-zt258 on 22/12/21.
//

import QuickLook
import SwiftUI

final class AttachmentPreview: UIViewControllerRepresentable {
  
  @State var isPresented: Bool
  var attachments: [Attachment]
  var selectedAttachment: Attachment
  private var controller: UIViewController?
  
  init(isPresented: Bool, attachments: [Attachment], selectedAttachment: Attachment) {
    self.isPresented = isPresented
    self.attachments = attachments
    self.selectedAttachment = selectedAttachment
  }
  
  func updateUIViewController(_ uiViewController: UIViewController, context: Context) { }
  
  func makeUIViewController(context: Context) -> UIViewController {
    let previewController = QLPreviewController()
    previewController.currentPreviewItemIndex = 2//attachments.firstIndex(of: selectedAttachment) ?? .zero
    previewController.dataSource = context.coordinator
    previewController.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(dismiss))
    let navigationController = UINavigationController(rootViewController: previewController)
    self.controller = navigationController
    return navigationController
  }
  
  @objc private func dismiss() {
    controller?.dismiss(animated: true, completion: nil)
  }
  
  func makeCoordinator() -> Coordinator {
    Coordinator(attachments: attachments, selectedAttachment: selectedAttachment)
  }
  
  class Coordinator: QLPreviewControllerDataSource {
    
    private var attachments: [Attachment]
    var selectedAttachment: Attachment

    internal init(attachments: [Attachment], selectedAttachment: Attachment) {
      self.attachments = attachments
      self.selectedAttachment = selectedAttachment
    }
    
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
      attachments.count
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
      attachments[index]
    }
    
  }
  
}

extension Attachment: QLPreviewItem {
  
  var previewItemURL: URL? {
    guard var documentDir = FileManager.default.urls(for: .documentDirectory, in: .allDomainsMask).first else{return nil}
    documentDir.appendPathComponent(name)
    return FileManager.default.fileExists(atPath: documentDir.absoluteString) ? documentDir : {
      try? data.write(to: documentDir)
      return documentDir
    }()
  }
  
  var previewItemTitle: String? { name }
  
}
