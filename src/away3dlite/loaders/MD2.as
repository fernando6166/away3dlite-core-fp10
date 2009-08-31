﻿package away3dlite.loaders{    import away3dlite.arcane;    import away3dlite.animators.*;	import away3dlite.animators.data.*;    import away3dlite.core.utils.*;        import flash.utils.*;		use namespace arcane;	    /**    * File loader for the Md2 file format.    */    public class MD2 extends AbstractParser    {		/** @private */        arcane override function prepareData(data:*):void        {        	md2 = Cast.bytearray(data);        				var a:int, b:int, c:int, ta:int, tb:int, tc:int, i1:int, i2:int, i3:int;			var i:int, uvs:Array = [];						// Make sure to have this in Little Endian or you will hate you life.			// At least I did the first time I did this for a while.			data.endian = Endian.LITTLE_ENDIAN;			// Read the header and make sure it is valid MD2 file			readMd2Header(data);			if (ident != 844121161 || version != 8)				throw new Error("Error loading MD2 file: Not a valid MD2 file/bad version");			// UV coordinates			//		Load them!			data.position = offset_st;			for (i = 0; i < num_st; i++)				uvs.push(data.readShort() / skinwidth, (data.readShort() / skinheight));							mesh._uvtData.length = mesh._vertices.length = num_tris*9;			vertices.length = num_tris*3;						// Faces			//		Creates the faces with the proper references to vertices			//		NOTE: DO NOT change the order of the variable assignments here, 			//			  or nothing will work.			data.position = offset_tris;			for (i = 0; i < num_tris; i++) {				i1 = i*3;				i2 = i1 + 1;				i3 = i1 + 2;								//collect vertices				a = data.readUnsignedShort();				b = data.readUnsignedShort();				c = data.readUnsignedShort();				vertices[i1] = a;				vertices[i2] = b;				vertices[i3] = c;								//collect indices				mesh._indices.push(i3, i2, i1);								//collect uvData 				ta = data.readUnsignedShort();				tb = data.readUnsignedShort();				tc = data.readUnsignedShort();				mesh._uvtData[i1*3] = uvs[ta*2];				mesh._uvtData[i1*3 + 1] = uvs[ta*2 + 1];				mesh._uvtData[i1*3 + 2] = 1;				mesh._uvtData[i2*3] = uvs[tb*2];				mesh._uvtData[i2*3 + 1] = uvs[tb*2 + 1];				mesh._uvtData[i2*3 + 2] = 1;				mesh._uvtData[i3*3] = uvs[tc*2];				mesh._uvtData[i3*3 + 1] = uvs[tc*2 + 1];				mesh._uvtData[i3*3 + 2] = 1;			}						// Frame animation data			//		This part is a little funky.			data.position = offset_frames;			readFrames(data);                        //setup vertices for the first frame            i = mesh._vertices.length;            vertices = mesh.frames[0].vertices;			while (i--)				mesh._vertices[i] = vertices[i];						if (material)				mesh.material = material;						mesh.buildFaces();                        mesh.type = ".Md2";        }                private var md2:ByteArray;        private var ident:int;        private var version:int;        private var skinwidth:int;        private var skinheight:int;        private var framesize:int;        private var num_skins:int;        private var num_vertices:int;        private var num_st:int;        private var num_tris:int;        private var num_glcmds:int;        private var num_frames:int;        private var offset_skins:int;        private var offset_st:int;        private var offset_tris:int;        private var offset_frames:int;        private var offset_glcmds:int;        private var offset_end:int;    	private var mesh:MovieMesh;		private var vertices:Vector.<Number> = new Vector.<Number>();				/**		 * Reads in all the frames		 */		private function readFrames(data:ByteArray):void		{			var sx:Number, sy:Number, sz:Number;			var tx:Number, ty:Number, tz:Number;			var fvertices:Vector.<Number>, frame:Frame;			var tvertices:Vector.<Number>;			var i:int, j:int, k:int, char:int;						for (i = 0; i < num_frames; i++) {				tvertices = new Vector.<Number>();				fvertices = new Vector.<Number>(num_tris*9, true);				frame = new Frame("", fvertices);				sx = data.readFloat();				sy = data.readFloat();				sz = data.readFloat();				tx = data.readFloat();				ty = data.readFloat();				tz = data.readFloat();								//read frame name				k = 0;				for (j = 0; j < 16; j++) {					char = data.readUnsignedByte();										if (int(char) >= 0x30 && int(char) <= 0x7A && k < 3)						frame.name += String.fromCharCode(char);										if (int(char) >= 0x30 && int(char) <= 0x39)						k++; 				}								// Note, the extra data.position++ in the for loop is there 				// to skip over a byte that holds the "vertex normal index"				for (j = 0; j < num_vertices; j++, data.position++)					tvertices.push((sx*data.readUnsignedByte() + tx)*scaling, (sy*data.readUnsignedByte() + ty)*scaling, (sz*data.readUnsignedByte() + tz)*scaling);								for (j = 0; j < num_tris*3; j++) {					fvertices[j*3] = tvertices[vertices[j]*3];					fvertices[j*3 + 1] = tvertices[vertices[j]*3 + 1];					fvertices[j*3 + 2] = tvertices[vertices[j]*3 + 2];				}				mesh.addFrame(frame);			}						vertices.fixed = true;		}		/**		 * Reads in all that MD2 Header data that is declared as private variables.		 * I know its a lot, and it looks ugly, but only way to do it in Flash		 */		private function readMd2Header(data:ByteArray):void		{			ident = data.readInt();			version = data.readInt();			skinwidth = data.readInt();			skinheight = data.readInt();			framesize = data.readInt();			num_skins = data.readInt();			num_vertices = data.readInt();			num_st = data.readInt();			num_tris = data.readInt();			num_glcmds = data.readInt();			num_frames = data.readInt();			offset_skins = data.readInt();			offset_st = data.readInt();			offset_tris = data.readInt();			offset_frames = data.readInt();			offset_glcmds = data.readInt();			offset_end = data.readInt();		}            	/**    	 * A scaling factor for all geometry in the model. Defaults to 1.    	 */        public var scaling:Number = 1;            	/**    	 * Controls the automatic centering of geometry data in the model, improving culling and the accuracy of bounding dimension values.    	 */        public var centerMeshes:Boolean;        		/**		 * Creates a new <code>Md2</code> object.		 */        public function MD2()        {            mesh = (_container = new MovieMesh()) as MovieMesh;                        binary = true;        }    }}