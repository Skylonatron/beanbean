//
//  BeanPod.swift
//  beanbean
//
//  Created by Skylar Jones on 3/11/24.
//

import SpriteKit

class BeanPod {
    
    var activeBean: Bean
    var sideBean: Bean
    
    init(activeBean: Bean, sideBean: Bean){
        self.activeBean = activeBean
        self.sideBean = sideBean
    }
    
    func active() -> Bool {
        return self.activeBean.active || self.sideBean.active
    }
}
