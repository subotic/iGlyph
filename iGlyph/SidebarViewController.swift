//
//  SidebarViewController.swift
//  iGlyph
//
//  Created by Ivan Subotic on 11.02.18.
//

import Cocoa


class SidebarViewController: NSViewController {

    @IBOutlet weak var sidebarView: NSView!
    @IBOutlet weak var titleLabel: NSTextField!
    @IBOutlet weak var disclosureButton: NSButton!
    @IBOutlet weak var headerView: NSView!
    
    var ad: IGlyphDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
}
