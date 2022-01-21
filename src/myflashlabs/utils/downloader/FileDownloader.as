// =================================================================================================
//
//	The MIT License (MIT)
//
//	Copyright (c) 2013-2022 MyFlashLabs.com
//
//	Permission is hereby granted, free of charge, to any person obtaining a copy
//	of this software and associated documentation files (the "Software"), to deal
//	in the Software without restriction, including without limitation the rights
//	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//	copies of the Software, and to permit persons to whom the Software is
//	furnished to do so, subject to the following conditions:
//
//	The above copyright notice and this permission notice shall be included in
//	all copies or substantial portions of the Software.
//
//	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//	THE SOFTWARE.
//
// =================================================================================================

package com.myflashlabs.utils.downloader
{
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;
import flash.events.ProgressEvent;
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;
import flash.net.URLLoader;
import flash.net.URLRequest;
import flash.net.URLRequestHeader;
import flash.net.URLStream;
import flash.utils.ByteArray;

public class FileDownloader extends EventDispatcher
{
	private var _url:String;
	private var _file:File;
	private var _bytesTotal:uint;
	private var _urlStream:URLStream;
	private var _loader:URLLoader;
	
	public function FileDownloader($url:String, $file:File)
	{
		_url = $url;
		_file = $file;
	}
	
	public function start():void
	{
		var request:URLRequest = new URLRequest(_url);
		_loader = new URLLoader();
		_loader.addEventListener(ProgressEvent.PROGRESS, initialProgress);
		_loader.load(request);
	}
	
	private function initialProgress(e:ProgressEvent):void
	{
		if(!isNaN(_loader.bytesTotal))
		{
			_bytesTotal = _loader.bytesTotal;
			_loader.removeEventListener(ProgressEvent.PROGRESS, initialProgress);
			_loader.close();
			
			startUrlStream();
		}
	}
	
	private function startUrlStream():void
	{
		var startPoint:uint = 0;
		
		// check if file is already available or not
		if(_file.exists)
		{
			var fs:FileStream = new FileStream();
			fs.open(_file, FileMode.READ);
			startPoint = fs.bytesAvailable;
			fs.close();
		}
		
		if(startPoint == _bytesTotal)
		{
			dispatchEvent(new Event(Event.COMPLETE));
			return;
		}
		
		var request:URLRequest = new URLRequest(_url);
		request.requestHeaders.push(new URLRequestHeader ("Range", "bytes=" + startPoint + "-" + _bytesTotal));
		
		_urlStream = new URLStream();
		_urlStream.addEventListener(ProgressEvent.PROGRESS, onProgress);
		_urlStream.addEventListener(Event.COMPLETE, onComplete);
		_urlStream.load(request);
	}
	
	private function onProgress(e:ProgressEvent):void
	{
		var byteArray:ByteArray = new ByteArray();
		_urlStream.readBytes(byteArray);
		
		var fs:FileStream = new FileStream();
		fs.open(_file, FileMode.UPDATE);
		var bytesLoaded:uint = fs.bytesAvailable + byteArray.length;
		fs.position = fs.bytesAvailable;
		
		fs.writeBytes(byteArray, 0, byteArray.length);
		fs.close();
		
		dispatchEvent(new ProgressEvent(ProgressEvent.PROGRESS, false, false, bytesLoaded, _bytesTotal));
	}
	
	private function onComplete(e:Event):void
	{
		_urlStream.removeEventListener(ProgressEvent.PROGRESS, onProgress);
		_urlStream.removeEventListener(Event.COMPLETE, onComplete);
		
		dispatchEvent(e);
	}
}
}
