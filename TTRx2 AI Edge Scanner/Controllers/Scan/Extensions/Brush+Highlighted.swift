/*
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import ScanditCaptureCore

extension Brush {
    static var highlighted: Brush {
        //return Brush(fill: .clear, stroke: .white, strokeWidth: 2)
       // return Brush(fill: UIColor(red: 7/255, green: 33/255, blue: 68/255, alpha: 0.4), stroke: UIColor(red: 7/255, green: 33/255, blue: 68/255, alpha: 1), strokeWidth: 2)
        //return Brush(fill: UIColor.green.withAlphaComponent(0.4), stroke: UIColor.green.withAlphaComponent(0.1), strokeWidth: 2)
        return Brush(fill: Utility.hexStringToUIColor(hex: "39DFA7").withAlphaComponent(0.3), stroke: Utility.hexStringToUIColor(hex: "39DFA7").withAlphaComponent(1.0), strokeWidth: 1)
    }
    
    static var removed: Brush {
        return Brush(fill: UIColor.red.withAlphaComponent(0.3), stroke: .red, strokeWidth: 1)
    }
    
    static var newlyAdded: Brush {
        return Brush(fill: Utility.hexStringToUIColor(hex: "00AFEF").withAlphaComponent(0.3), stroke: Utility.hexStringToUIColor(hex: "00AFEF").withAlphaComponent(1.0), strokeWidth: 1)
    }
    static var clear: Brush {
        return Brush(fill: Utility.hexStringToUIColor(hex: "000000").withAlphaComponent(0.3), stroke: Utility.hexStringToUIColor(hex: "000000").withAlphaComponent(1.0), strokeWidth: 1)
    }
}
