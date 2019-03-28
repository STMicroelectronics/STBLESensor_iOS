/*
 * Copyright (c) 2019  STMicroelectronics – All rights reserved
 * The STMicroelectronics corporate logo is a trademark of STMicroelectronics
 *
 * Redistribution and use in source and binary forms, with or without modification,
 * are permitted provided that the following conditions are met:
 *
 * - Redistributions of source code must retain the above copyright notice, this list of conditions
 *   and the following disclaimer.
 *
 * - Redistributions in binary form must reproduce the above copyright notice, this list of
 *   conditions and the following disclaimer in the documentation and/or other materials provided
 *   with the distribution.
 *
 * - Neither the name nor trademarks of STMicroelectronics International N.V. nor any other
 *   STMicroelectronics company nor the names of its contributors may be used to endorse or
 *   promote products derived from this software without specific prior written permission.
 *
 * - All of the icons, pictures, logos and other images that are provided with the source code
 *   in a directory whose title begins with st_images may only be used for internal purposes and
 *   shall not be redistributed to any third party or modified in any way.
 *
 * - Any redistributions in binary form shall not include the capability to display any of the
 *   icons, pictures, logos and other images that are provided with the source code in a directory
 *   whose title begins with st_images.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR
 * IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY
 * AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER
 * OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
 * OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY
 * OF SUCH DAMAGE.
 */

import Foundation

struct FFTSettings {
    let winType:WindowType
    let odr:UInt16
    let fullScale:UInt8
    let size:UInt16
    let acqusitionTime_s:UInt32
    let subRange:UInt8
    let overlap:UInt8
    
    enum WindowType:UInt8, CaseIterable{
        case RECTANGULAR = 0x00
        case HANNING = 0x01
        case HAMMING = 0x02
        case FLAT_TOP = 0x03
    }
    
    func copyWith(winType: WindowType? = nil,
                  odr:UInt16? = nil,
                  fullScale: UInt8? = nil,
                  size: UInt16? = nil,
                  acqusitionTime_s: UInt32? = nil,
                  subRange: UInt8? = nil,
                  overlap: UInt8? = nil)-> FFTSettings{
        return FFTSettings(winType: winType ?? self.winType,
                           odr:odr ?? self.odr,
                           fullScale: fullScale ?? self.fullScale,
                           size: size ?? self.size,
                           acqusitionTime_s: acqusitionTime_s ?? self.acqusitionTime_s,
                           subRange: subRange ?? self.subRange,
                           overlap: overlap ?? self.overlap)
    }
    
}
