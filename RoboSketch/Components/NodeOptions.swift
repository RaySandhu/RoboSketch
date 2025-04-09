//
//  NodeOptions.swift
//  RoboSketch
//
//  Created by Ray Sandhu on 2025-04-09.
//


// NodeOptions.swift
import SwiftUI

struct NodeOptions {
    static let options: [String: String] = [
        "Dance": """
        
        def dance():
            background_music('angry.mp3')
            music_set_volume(50)
            for _ in range(2):
                crawler.do_action('stand', 1, speed)
                crawler.do_action('sit', 1, speed)
                crawler.do_action('push_up', 1, speed)
                crawler.do_action('backward', 1, speed)
                crawler.do_action('twist', 1, speed)
        
        """,
        "Approach": """
        
        def approach():
            for _ in range(2):
                crawler.do_action('forward', 2, speed)
                delay(200)

            crawler.do_action('stand', 1, speed)
            delay(2000)
        
        """
    ]
}
