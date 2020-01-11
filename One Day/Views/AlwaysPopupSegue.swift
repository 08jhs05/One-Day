//
//  AlwaysPopupSegue.swift
//  One Day
//
//  Created by Jae Ho Shin on 2020-01-06.
//  Copyright © 2020 Jae Ho Shin. All rights reserved.
//

import UIKit

class AlwaysPopupSegue : UIStoryboardSegue, UIAdaptivePresentationControllerDelegate
{
    override init(identifier: String?, source: UIViewController, destination: UIViewController)
    {
        super.init(identifier: identifier, source: source, destination: destination)
        destination.modalPresentationStyle = UIModalPresentationStyle.pageSheet
        destination.presentationController!.delegate = self
    }
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
}
