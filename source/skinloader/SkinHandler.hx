package skinloader;

// this is here so the game doesnt crash because of no framework params
#if (MODS && polymod)
import polymod.Polymod;

class SkinHandler
{
	public static var swagMeta:String;
	public static var metadataArrays:Array<String> = [];

	public static function loadMods()
	{
		loadModMetadata();

		Polymod.init({
			modRoot: "skins/",
			dirs: skinloader.SkinList.getActiveskins(metadataArrays),
			errorCallback: function(error:PolymodError)
			{
				// trace(error.message);
			},
			frameworkParams: {
				assetLibraryPaths: ["songs" => "songs", "shared" => "shared", "fonts" => "fonts"]
			}
		});
	}

	public static function loadModMetadata()
	{
		metadataArrays = [];

		var tempArray = Polymod.scan("skins/", "*.*.*", function(error:PolymodError)
		{
			trace(error.message);
		});

		for (metadata in tempArray)
		{
			swagMeta = metadata.id;
			metadataArrays.push(metadata.id);
			skinloader.SkinList.skinMetadatas.set(metadata.id, metadata);
		}
	}
}
#end
