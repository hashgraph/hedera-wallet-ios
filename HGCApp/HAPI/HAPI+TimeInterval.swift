//
//  Copyright 2019 Hedera Hashgraph LLC
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Foundation

extension TimeInterval {
    func protoDuration() -> Proto_Duration {
        var d = Proto_Duration.init()
        let o = self.extractSecondsAndNanos()
        d.seconds = o.seconds
        return d
    }
    
    func protoTimestamp() -> Proto_Timestamp {
        var d = Proto_Timestamp.init()
        let o = self.extractSecondsAndNanos()
        d.seconds = o.seconds
        d.nanos = o.nanos
        return d
    }
    
    func extractSecondsAndNanos() -> (seconds:Int64, nanos:Int32) {
        let seconds = Int64(floor(self))
        let nanos = Int32((self - TimeInterval(seconds)) * 1000000000)
        return (seconds, nanos)
    }
}
