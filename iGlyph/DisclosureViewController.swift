//
//  SidebarViewController.swift
//  iGlyph
//
//  Created by Ivan Subotic on 11.02.18.
//
//  Tutorial Site: http://jpopham.github.io/01-sidebar-swift-OSX/
//

import Cocoa


class DisclosureViewController: NSViewController {

    @IBOutlet weak var panelView: NSView!
    @IBOutlet weak var titleTextField: NSTextField!
    @IBOutlet weak var disclosureButton: NSButton!
    @IBOutlet weak var headerView: NSView!
    
    var ad: IGlyphDelegate!
    var closingConstraint: NSLayoutConstraint!
    var isClosed:Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        self.panelView.removeFromSuperview()
        self.view.addSubview(self.panelView)
        
        // the header containing the title and the disclosure button will be gray by default
        // set the background of the disclosed part of the view to white (or whatever other colour you want)
        self.panelView.wantsLayer = true
        self.panelView.layer?.backgroundColor = (NSColor.white as! CGColor)
        
        // add horizontal constraints
        let d1: NSMutableDictionary = NSMutableDictionary()
        d1.setValue(panelView, forKey: "_panelView")
        
        // TODO: Updated so it compiles but needs to be checkt if it is correct. I don't really know what it does.
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[_panelView]|", options: NSLayoutConstraint.FormatOptions.alignAllBottom, metrics: nil, views: d1 as! [String : Any]))
        
        // add vertical constraints
        let d2: NSMutableDictionary = NSMutableDictionary()
        d2.setValue(panelView, forKey: "_panelView")
        d2.setValue(self.headerView, forKey: "_headerView")
        
        // TODO: Updated so it compiles but needs to be checkt if it is correct. I don't really know what it does.
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[_headerView][_panelView]", options: NSLayoutConstraint.FormatOptions.alignAllBottom, metrics: nil, views: d2 as! [String : Any]))
    }
    
    override var title: String! {
        get {
            return super.title
        }
        
        set {
            super.title = title
            titleTextField.stringValue = title
        }
    }
    
    override func awakeFromNib() {
        // don't do anything until isClosed is initialised
        if self.isClosed != nil{
            openDisclosure(sender: self,open:false,onlyOneOpen:false)
            if isClosed == false{
                openDisclosure(sender: self,open:true,onlyOneOpen:false)
            }
        }
    }
    
    @IBAction func toggleDisclosure(sender: NSButton) {
        // called when the disclosure button is pressed
        if (self.isClosed == true) {
            openDisclosure(sender: sender,open:true,onlyOneOpen:true)
        } else {
            openDisclosure(sender: sender,open:false,onlyOneOpen:true)
        }
    }
    
    func openDisclosure(sender: AnyObject, open:Bool, onlyOneOpen:Bool){
        ad = NSApplication.shared.delegate as! IGlyphDelegate
        if (open==false){
            // close an open panel
            var distanceFromHeaderToBottom:CGFloat = NSMinY(self.view.bounds) - NSMinY(self.headerView.frame)
            
            if let cc = self.closingConstraint{
                // if the closing contraint has been initialised, no need to do anything
            } else {
                // The closing constraint is going to tie the bottom of the header view to the bottom of the overall disclosure view.
                // Initially, it will be offset by the current distance, but we'll be animating it to 0.
                self.closingConstraint = NSLayoutConstraint(item: self.headerView, attribute: NSLayoutConstraint.Attribute.bottom, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.view, attribute: NSLayoutConstraint.Attribute.bottom, multiplier: 1, constant: distanceFromHeaderToBottom)
            }
            self.closingConstraint.constant =  distanceFromHeaderToBottom
            self.view.addConstraint(self.closingConstraint)
            
            NSAnimationContext.runAnimationGroup({ context in
                context.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
                // Animate the closing constraint to 0, causing the bottom of the header to be flush with the bottom of the overall disclosure view.
                self.closingConstraint.animator().constant = 0
                self.disclosureButton.title = "►"
            }, completionHandler:{
                self.isClosed = true
            })
        }
        else
        {
            // open a closed panel
            NSAnimationContext.runAnimationGroup({ context in
                context.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
                // Animate the closing constraint from 0, causing the panel to open.
                self.closingConstraint.animator().constant -=  self.panelView.frame.size.height
                self.disclosureButton.title = "▼"
            }, completionHandler:{
                self.isClosed = false
                
                // Set the focus to the appropriate input field if required - replace "firstControl" with the name of
                // the control from each panel that you want to have the focus when the panel is opened
                /*
                 if self === self.ad.sidebar1{
                 self.ad.window.makeFirstResponder(self.ad.sidebar1.firstControl)
                 }
                 if self === self.ad.sidebar2{
                 self.ad.window.makeFirstResponder(self.ad.sidebar2.forstControl)
                 }
                 if self === self.ad.sidebar3{
                 self.ad.window.makeFirstResponder(self.ad.sidebar3.firstControl)
                 }
                 if self === self.ad.sidebar4{
                 self.ad.window.makeFirstResponder(self.ad.sidebar4.firstControl)
                 }
                 */
                
            })
            /*
            if (onlyOneOpen == true){
                // close other bars
                // adjust this segment dependant on the number of panels you have
                if ad.sidebar1 === self {
                    ad.sidebar2.isClosed = false
                    ad.sidebar2.toggleDisclosure(sender)
                    ad.sidebar3.isClosed = false
                    ad.sidebar3.toggleDisclosure(sender)
                    ad.sidebar4.isClosed = false
                    ad.sidebar4.toggleDisclosure(sender)
                }
                if ad.sidebar2 === self {
                    ad.sidebar1.isClosed = false
                    ad.sidebar1.toggleDisclosure(sender)
                    ad.sidebar3.isClosed = false
                    ad.sidebar3.toggleDisclosure(sender)
                    ad.sidebar4.isClosed = false
                    ad.sidebar4.toggleDisclosure(sender)
                }
                if ad.sidebar3 === self {
                    ad.sidebar1.isClosed = false
                    ad.sidebar1.toggleDisclosure(sender)
                    ad.sidebar2.isClosed = false
                    ad.sidebar2.toggleDisclosure(sender)
                    ad.sidebar4.isClosed = false
                    ad.sidebar4.toggleDisclosure(sender)
                }
                if ad.sidebar4 === self {
                    ad.sidebar1.isClosed = false
                    ad.sidebar1.toggleDisclosure(sender)
                    ad.sidebar2.isClosed = false
                    ad.sidebar2.toggleDisclosure(sender)
                    ad.sidebar3.isClosed = false
                    ad.sidebar3.toggleDisclosure(sender)
                }
            }
            */
            
        }
        
    }
    
}
