//
//  Config.swift
//  demoNuance
//
//  Created by Atal Bansal on 11/07/16.
//  Copyright © 2016 Atal Bansal. All rights reserved.
//

import Foundation
import SpeechKit

var SKSAppKey = "680e4bd60ee60c762b45036a6f44fe39ade6aa5b7d5dd433b7892ba1d73b543f4aa016588622ceb167d11bd616190fc300b91e7d16f2b1cd7bdc6f5218c39262"
var SKSAppId = "NMDPTRIAL_amitg3_chetu_com20160711061422"
var SKSServerHost = "sslsandbox.nmdp.nuancemobility.net"
var SKSServerPort = "443"

var SKSLanguage = "!LANGUAGE!"

var SKSServerUrl = String(format: "nmsps://%@@%@:%@", SKSAppId, SKSServerHost, SKSServerPort)

// Only needed if using NLU/Bolt
var SKSNLUContextTag = "!NLU_CONTEXT_TAG!"


let LANGUAGE = SKSLanguage == "!LANGUAGE!" ? "eng-USA" : SKSLanguage


var lastRecogniation:SKRecognition = SKRecognition()