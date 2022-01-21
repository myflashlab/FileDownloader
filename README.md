# FileDownloader Pure AS3 class
Init this simple to use library in your Adobe AIR project to download big files to your project. It will write downloaded bytes into OS file and keeps nothing in your app's runtime ram. Even if the app shuts down suddenly or if internet connection drops, the download can be resumed from where it was cut off.

There can be many other cool features be added to this class like passing a URLRequest instead of a simple URL String or *pause*, *stop* or even download queue which I didn't implement because the project I'm working on does not need that. But if you feel like you like this little tool, feel free to make a pull-request.

## AS3 Usage

```actionscript
var url:String = "https://domain.com/big_file.zip";
var file:File = File.desktopDirectory.resolvePath("big_file.zip");

// init the class and pass the URL to be downloaded + the file location where you want to save it.
var _fileDownloader:FileDownloader = new FileDownloader(url, file);

_fileDownloader.addEventListener(ProgressEvent.PROGRESS, onDownloadProgress);
_fileDownloader.addEventListener(Event.COMPLETE, onDownloadComplete);

// start the download progress
_fileDownloader.start();

function onDownloadProgress(e:ProgressEvent):void
{
    trace(Math.round(e.bytesLoaded / e.bytesTotal * 100), "%");
}

function onDownloadComplete(e:Event):void
{
	_fileDownloader.removeEventListener(ProgressEvent.PROGRESS, onDownloadProgress);
	_fileDownloader.removeEventListener(Event.COMPLETE, onDownloadComplete);
		
	trace("download completed");
}
```