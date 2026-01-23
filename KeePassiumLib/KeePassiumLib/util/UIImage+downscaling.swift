//  KeePassium Password Manager
//  Copyright © 2018-2025 KeePassium Labs <info@keepassium.com>
//
//  This program is free software: you can redistribute it and/or modify it
//  under the terms of the GNU General Public License version 3 as published
//  by the Free Software Foundation: https://www.gnu.org/licenses/).
//  For commercial licensing, please contact the author.

import UIKit

public extension UIImage {

    func downscalingToSquare(maxSidePixels: CGFloat) -> UIImage? {
        return downscalingToSquare(maxSidePoints: maxSidePixels / UIScreen.main.scale)
    }

    func downscalingToSquare(maxSidePoints: CGFloat) -> UIImage? {
        let targetSize = CGSize(width: maxSidePoints, height: maxSidePoints)
        let scaleFactor = min(1.0, maxSidePoints / max(size.width, size.height))

        let scaledSize = CGSize(width: size.width * scaleFactor, height: size.height * scaleFactor)

        let origin = CGPoint(
            x: (targetSize.width - scaledSize.width) / 2.0,
            y: (targetSize.height - scaledSize.height) / 2.0
        )

        let renderer = UIGraphicsImageRenderer(size: targetSize, format: .default())
        let resized = renderer.image { _ in
            self.draw(in: CGRect(origin: origin, size: scaledSize))
        }
        return resized.withRenderingMode(self.renderingMode)
    }
}
