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
import AVFoundation

/**
 * Audio callback called when an audio buffer can be reused
 * userData: pointer to our SyncQueue with the buffer to reproduce
 * queue: audio queue where the buffer will be played
 * buffer: audio buffer that must be filled
 */
fileprivate func audioCallback(usedData:UnsafeMutableRawPointer?,queue:AudioQueueRef, buffer:AudioQueueBufferRef){

    // SampleQueue *ptr = (SampleQueue*) userData
    let sampleQueuePtr = usedData?.assumingMemoryBound(to: BlueVoiceSyncQueue.self)
    //NSData* data = sampleQueuePtr->pop();
    let data = sampleQueuePtr?.pointee.pop();
    //uint8* temp = (uint8*) buffer->mAudioData
    let temp = buffer.pointee.mAudioData.assumingMemoryBound(to: UInt8.self);

    //memcpy(temp,data)
    data?.copyBytes(to: temp, count: Int(buffer.pointee.mAudioDataByteSize));

    AudioQueueEnqueueBuffer(queue, buffer, 0, nil);
}


public class W2STAudioPlayBackController{

    private static let NUM_BUFFERS=9;

    private var mAudioFormat:AudioStreamBasicDescription;

    //audio queue where play the sample
    private var queue:AudioQueueRef?=nil;
    //quueue of audio buffer to play
    private var buffers:[AudioQueueBufferRef?] = Array(repeating:nil, count: NUM_BUFFERS)
    //synchronized queue used to store the audio sample from the node
    // when an audio buffer is free it will be filled with sample from this object
    private var mSyncAudioQueue:BlueVoiceSyncQueue;

    private var mIsMute:Bool=false;

    private var mIsPlayBackStart=false;


    public var mute:Bool=false{
        didSet{
            if(mute){
                AudioQueueSetParameter(queue!, kAudioQueueParam_Volume,0.0);
            }else{
                AudioQueueSetParameter(queue!, kAudioQueueParam_Volume,1.0);
            }
        }
    }


    init(_ param:BlueSTSDKAudioCodecSettings){
        //https://developer.apple.com/library/mac/documentation/MusicAudio/Reference/CoreAudioDataTypesRef/#//apple_ref/c/tdef/AudioStreamBasicDescription
        mAudioFormat = AudioStreamBasicDescription(
            mSampleRate: Float64(param.samplingFequency),
                mFormatID: kAudioFormatLinearPCM,
                mFormatFlags: kLinearPCMFormatFlagIsSignedInteger,
                mBytesPerPacket: UInt32(param.bytesPerSample*param.channels),
                mFramesPerPacket: 1,
                mBytesPerFrame: UInt32(param.bytesPerSample*param.channels),
                mChannelsPerFrame: UInt32(param.channels),
                mBitsPerChannel: UInt32(8 * param.bytesPerSample),
                mReserved: 0);
        mSyncAudioQueue = BlueVoiceSyncQueue();

        //create the audio queue
        AudioQueueNewOutput(&mAudioFormat,audioCallback, &mSyncAudioQueue,nil, nil, 0, &queue);
        //create the system audio buffer that will be filled with the data inside the mSyncAudioQueue
        let bufferSizeByte = param.samplePerBlock*Int(param.bytesPerSample);
        for i in 0..<W2STAudioPlayBackController.NUM_BUFFERS{
            AudioQueueAllocateBuffer(queue!,
                    UInt32(bufferSizeByte),
                    &buffers[i]);

            if let buffer = buffers[i]{
                buffer.pointee.mAudioDataByteSize = UInt32(bufferSizeByte);
                memset(buffer.pointee.mAudioData,0,bufferSizeByte);
                AudioQueueEnqueueBuffer(queue!, buffer, 0, nil);
            }
        }//for
        //start plaing the audio

    }

    public func playSample(sample:Data){
        if(!mIsPlayBackStart){
            AudioQueueStart(queue!, nil);
            mIsPlayBackStart=true;
        }
        mSyncAudioQueue.push(data: sample);
    }

    /// free the audio initialized audio queues
    deinit{
        AudioQueueStop(queue!, true);
        buffers.forEach{ buff in
            if let buffer = buff{
                AudioQueueFreeBuffer(queue!,buffer);
            }
        }
    }
}
