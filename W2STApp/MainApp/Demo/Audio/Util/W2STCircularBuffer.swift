/*
 * Copyright (c) 2017  STMicroelectronics – All rights reserved
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


/// Circular Buffer that manage audio samples
public class W2STCircularBuffer {
    
    /// sample type
    public typealias Sample = Int16;
    
    /// sample type after scaling
    public typealias ScaleSample = CGFloat;
    
    
    /// type to use to compute the signal energy
    private typealias SquareSample = Double;

    /// all sample will be scaled by this value before store it
    private let mScaleFactor:ScaleSample;
    
    /// array that will contain all the sample
    private var mData:[ScaleSample];

    
    /// position where store the next value
    private var mNextIdx=0;

    
    /// sum of the square of all the value in the circular buffer
    private var mSumSquare:SquareSample=0;

    
    /// size of the circular buffer
    public var count:UInt{
        return UInt(mData.count);
    }

    
    /// create a circular buffer
    ///
    /// - Parameters:
    ///   - size: size of th buffer
    ///   - scale: scale factor to apply to all the sample store in the buffer
    public init(size:Int, scale:ScaleSample){
        mScaleFactor=scale;
        mData = Array<ScaleSample>(repeating: ScaleSample(0), count: size);
    }


    /// add a value into the array
    ///
    /// - Parameter val: value to add
    public func append(_ val:Sample){

        objc_sync_enter(self)
        defer { objc_sync_exit(self) }

        let scaleVal = ScaleSample(val)*mScaleFactor;
        //we have to remove a element
        if(mNextIdx>=mData.count){
            let idx = mNextIdx % mData.count;
            let oldVal = mData[idx];
            mData[idx]=scaleVal;
            //update square sum
            mSumSquare -= SquareSample(oldVal*oldVal);
            mSumSquare += SquareSample(scaleVal*scaleVal);
            mNextIdx += 1;
        }else{
            mSumSquare += SquareSample(scaleVal*scaleVal);
            mData[mNextIdx]=scaleVal;
            mNextIdx += 1;
        }//if-else
    }



    public func dumpTo(_ snapshot: inout [ScaleSample]){
      
        objc_sync_enter(self)
        defer { objc_sync_exit(self) }

        let snapshotLenght = min(snapshot.count,mData.count);
        for i in 0 ... snapshotLenght-1{
            let idx = (mNextIdx+i) % mData.count;
            snapshot[i] = mData[idx]
        }

    }

}
