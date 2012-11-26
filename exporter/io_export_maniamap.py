import bpy
import json
import mathutils as Math
import os
import math

bl_info = {
    "name": "Export Mania Map",
    "author": "Mateusz Osowski",
    "version": (1, 0),
    "blender": (2, 6, 2),
    "api": 36079,
    "location": "File > Export > Mania Map",
    "description": "Export Mania Map",
    "category": "Import-Export"}

from bpy.props import (StringProperty, BoolProperty)

from bpy_extras.io_utils import (ExportHelper, axis_conversion)

class ExportMODEL(bpy.types.Operator, ExportHelper):
    bl_idname = "export_scene.bmap"
    bl_label = 'Export Mania Map'

    filename_ext = ".bmap"
    filter_glob = StringProperty(
            default="*.bmap",
            options={'HIDDEN'},
            )

    def invoke(self, context, event):
         
        if not self.filepath:
            blend_filepath = context.blend_data.filepath
            if not blend_filepath:
                blend_filepath = "~/untitled"
            else:
                blend_filepath = os.path.splitext (blend_filepath) [0]

            self.filepath = blend_filepath + self.filename_ext
        context.window_manager.fileselect_add(self)
        return {'RUNNING_MODAL'}
        
    def execute(self, context):
        keywords = self.as_keywords(ignore=("filter_glob","check_existing"))
        return save(self, context, keywords['filepath'])

def menu_func_export(self, context):
    self.layout.operator(ExportMODEL.bl_idname, text="Mania Map (.bmap)")

def register():
    bpy.utils.register_module(__name__)
    bpy.types.INFO_MT_file_export.append(menu_func_export)

def unregister():
    bpy.utils.unregister_module(__name__)
    bpy.types.INFO_MT_file_export.remove(menu_func_export)

if __name__ == "__main__":
    register()    
    
def tileCoordinates(object):
    return (math.floor(object.location.x/2), math.floor(object.location.y/2))   
   
def tileRotation(object):       
    return math.floor( ((-object.rotation_euler.z)%(math.pi*2)) / (math.pi/2) + 0.5)%4

def tileMapLayer(object):
    return math.floor(object.location.z/2 + 0.5)
    
def gremlinCoord(location):
    return [location[0], location[2], location[1]]

def save(operator,context, filepath=""):
    tileSet = { }
    tileSet["TileSpikes"] = { "code": 1 }
    tileSet["TileWall"] = { "code": 2 }
    tileSet["TileFloorNice"] = { "code": 3 }
    tileSet["TileFloorDep"] = { "code": 4 }
    tileSet["TileFloorHappy"] = { "code": 5 }
    tileSet["TileBlock"] = { "code": 6 }
    tileSet["TileFade"] = { "code": 7 }
    tileSet["TileFadeCorner"] = { "code": 8 }
    tileSet["TileSpikesCorner"] = { "code": 9 }    
    tileSet["TileSpikesOuterCorner"] = { "code": 10 }
    tileSet["TileFadeOuterCorner"] = { "code": 11 }
    tileSet["TileGrass"] = { "code": 12 }
    tileSet["TileGrassSlot"] = { "code": 13 }
    tileSet["TileVortal"] = { "code": 14 }
    
    
    tileNameList = []
    for tileName in tileSet.keys():
        tileNameList.append(tileName)
    tileNameList.sort()
    tileNameList.reverse()
        
    level = { }
    level["width"] = 0
    level["height"] = 0
    level["layers"] = 0
    level["start"] = [0, 0, 0]
    level["spawners"] = []
    level["pickables"] = []
    level["crates"] = []
    
    tiles = [ ]
   
    for sel in bpy.context.selected_objects:
        if sel.type == "MESH":
            for tileName in tileNameList:
                print(sel.name, tileName)
                if sel.name.find(tileName) != -1:
                    (x,y) = tileCoordinates(sel)
                    rotation = tileRotation(sel)
                    layerId = tileMapLayer(sel)
                    if x + 1> level["width"]:
                        level["width"] = x + 1
                    if y + 1> level["height"]:
                        level["height"] = y + 1
                    if layerId + 1 > level["layers"]:
                        level["layers"] = layerId + 1
                    tiles.append( (tileName,x,y,rotation,layerId) )
                    break
            if sel.name == "START":
                level["start"] = gremlinCoord(sel.location)
                
            if sel.name.find("SPAWN") != -1:
                spawner = { }
                spawner["delay"] = sel["delay"]
                spawner["speed"] = sel["speed"]
                spawner["position"] = gremlinCoord(sel.location)
                spawner["rotation"] = -sel.rotation_euler.z
                if sel.name.find("/BLADE") != -1:
                    spawner["type"] = "blade"
                level["spawners"].append(spawner)
                
            if sel.name.find("PICK") != -1:
                pickable = { }
                pickable["position"] = gremlinCoord(sel.location)
                if sel.name.find("/H") != -1:
                    pickable["type"] = "h"
                if sel.name.find("/F") != -1:
                    pickable["type"] = "f"
                if sel.name.find("/C") != -1:
                    pickable["type"] = "c"
                if sel.name.find("/M") != -1:
                    pickable["type"] = "m"
                if sel.name.find("/POINT") != -1:
                    pickable["type"] = "point"
                if sel.name.find("/EYE") != -1:
                    pickable["type"] = "eye"
                level["pickables"].append(pickable)
                
            if sel.name[:5] == "CRATE":
                crate = { }
                crate["position"] = gremlinCoord(sel.location)
                level["crates"].append(crate)
                
                
                
               
                
        
    print("Preparing map " + str(level["width"]) + " x " + str(level["height"]) + ", " + str(level["layers"]) + " layers.")
    for layerId in range(0,level["layers"]):
        layer = [ ]
        for xFill in range(0, level["width"]):
            row = [0] * level["height"]
            layer.append(row)
            
        level["layer" + str(layerId)] = layer
        
    for (tileName,x,y,rotation,layerId) in tiles:
        level["layer" + str(layerId)][x][y] = (tileSet[tileName]["code"], rotation)
        
    outFile = open(filepath, "wt")
    outFile.write(json.dumps({"tileSet": tileSet, "level": level}))
    outFile.close()

    return {'FINISHED'}
                
