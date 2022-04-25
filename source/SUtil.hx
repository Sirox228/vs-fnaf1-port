package;

#if android
import android.AndroidTools;
import android.stuff.Permissions;
#end
import lime.app.Application;
import openfl.events.UncaughtErrorEvent;
import openfl.utils.Assets as OpenFlAssets;
import openfl.Lib;
import haxe.CallStack.StackItem;
import haxe.CallStack;
import haxe.io.Path;
import sys.FileSystem;
import sys.io.File;
import flash.system.System;

/**
 * author: Saw (M.A. Jigsaw)
 * deleted all here: Sirox
 */

using StringTools;

class SUtil {
	#if android
	private static var grantedPermsList:Array<Permissions> = AndroidTools.getGrantedPermissions(); 
	private static var aDir:String = null; // android dir 
	public static var sPath:String = AndroidTools.getExternalStorageDirectory(); // storage dir
	#end

	static public function getPath():String {
		#if android
		if (aDir != null && aDir.length > 0) {
			return aDir;
		} else {
			aDir = sPath + "/" + "." + Application.current.meta.get("file") + "/";
		}
		return aDir;
		#else
		return "";
		#end
	}

	static public function doTheCheck() {
		#if android
		if (!grantedPermsList.contains(Permissions.READ_EXTERNAL_STORAGE) || !grantedPermsList.contains(Permissions.WRITE_EXTERNAL_STORAGE)) {
			if (AndroidTools.sdkVersion > 23 || AndroidTools.sdkVersion == 23) {
				AndroidTools.requestPermissions([Permissions.READ_EXTERNAL_STORAGE, Permissions.WRITE_EXTERNAL_STORAGE]);
			}
		}

		if (!grantedPermsList.contains(Permissions.READ_EXTERNAL_STORAGE) || !grantedPermsList.contains(Permissions.WRITE_EXTERNAL_STORAGE)) {
			if (AndroidTools.sdkVersion > 23 || AndroidTools.sdkVersion == 23) {
				SUtil.applicationAlert("Permissions", "If you accepted the permisions for storage, good, you can continue, if you not the game can't run without storage permissions please grant them in app settings" 
					+ "\n" + "Press Ok To Close The App");
			} else {
				SUtil.applicationAlert("Permissions", "The Game can't run without storage permissions please grant them in app settings" 
					+ "\n" + "Press Ok To Close The App");
			}
		}

		if (!FileSystem.exists(sPath + "/" + "." + Application.current.meta.get("file"))){
			FileSystem.createDirectory(sPath + "/" + "." + Application.current.meta.get("file"));
		}
		if (!FileSystem.exists(SUtil.getPath() + "crash")){
			FileSystem.createDirectory(SUtil.getPath() + "crash");
		}
		#end
	}

	static public function gameCrashCheck() {
		Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onCrash);
	}

	static public function onCrash(e:UncaughtErrorEvent):Void {
		var callStack:Array<StackItem> = CallStack.exceptionStack(true);
		var dateNow:String = Date.now().toString();
		dateNow = StringTools.replace(dateNow, " ", "_");
		dateNow = StringTools.replace(dateNow, ":", "'");
		var path:String = "crash/" + "crash_" + dateNow + ".txt";
		var errMsg:String = "";

		for (stackItem in callStack) {
			switch (stackItem) {
				case FilePos(s, file, line, column):
					errMsg += file + " (line " + line + ")\n";
				default:
					Sys.println(stackItem);
			}
		}

		errMsg += e.error;

		if (!FileSystem.exists(SUtil.getPath() + "crash")){
			FileSystem.createDirectory(SUtil.getPath() + "crash");
		}

		sys.io.File.saveContent(SUtil.getPath() + path, errMsg + "\n");

		Sys.println(errMsg);
		Sys.println("Crash dump saved in " + Path.normalize(path));
		Sys.println("Making a simple alert ...");

		SUtil.applicationAlert("Uncaught Error :(, The Call Stack: ", errMsg);
		System.exit(0);
	}

	private static function applicationAlert(title:String, description:String) {
		Application.current.window.alert(description, title);
	}

	static public function saveContent(fileName:String = "file", fileExtension:String = ".json", fileData:String = "you forgot something to add in your code"){
		if (!FileSystem.exists(SUtil.getPath() + "saves")){
			FileSystem.createDirectory(SUtil.getPath() + "saves");
		}

		File.saveContent(SUtil.getPath() + "saves/" + fileName + fileExtension, fileData);
		#if android
		SUtil.applicationAlert("Done Action :)", "File Saved Successfully!");
		#end
	}

	static public function copyContent(copyPath:String, savePath:String) {
		if (!FileSystem.exists(savePath)){
			var bytes = OpenFlAssets.getBytes(copyPath);
			File.saveBytes(savePath, bytes);
		}
	}
}
