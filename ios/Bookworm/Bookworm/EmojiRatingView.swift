//
//  EmojiRatingView.swift
//  Bookworm
//
//  Created by Mac Van Anh on 5/16/20.
//  Copyright © 2020 Mac Van Anh. All rights reserved.
//

import SwiftUI

struct EmojiRatingView: View {
    let rating: Int16
    
    var body: some View {
        if rating <= 4 {
            return Text("\(rating)")
        }
        return Text("5")
    }
}

struct EmojiRatingView_Previews: PreviewProvider {
    static var previews: some View {
        EmojiRatingView(rating: 3)
    }
}
