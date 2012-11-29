import bpy
import json
import mathutils as Math
import os

bl_info = {
    "name": "Export Orc Model",
    "author": "Mateusz Osowski",
    "version": (1, 0),
    "blender": (2, 6, 2),
    "api": 36079,
    "location": "File > Export > Orc MODEL",
    "description": "Export Orc MODEL (json based)",
    "category": "Import-Export"}

from bpy.props import (StringProperty, BoolProperty)

from bpy_extras.io_utils import (ExportHelper, axis_conversion)

class ExportMODEL(bpy.types.Operator, ExportHelper):
    bl_idname = "export_scene.orc"
    bl_label = 'Export Orc MODEL'

    filename_ext = ".orcm"
    filter_glob = StringProperty(
            default="*.orcm;*.orcs",
            options={'HIDDEN'},
            )

    layout = "pos,norm,uv0,tan"

    data_layout = StringProperty(
            name = "Layout",
            default = layout
            )    

    uv_mirror_y = BoolProperty(
			name = "UV flip Y",
			default = False
			)

    def invoke(self, context, event):
        for sel in bpy.context.selected_objects:
            if sel.type == 'ARMATURE':
                self.data_layout = "pos,norm,uv0,tan,bones,weights"
            if sel.type == 'MESH':
                if sel.name[:6] != "COL2D/":
                    modelname = sel.name
                
        if not self.filepath:
            blend_filepath = context.blend_data.filepath
            if not blend_filepath:
                blend_filepath = "~/untitled"
            else:
                blend_filepath = os.path.splitext (blend_filepath) [0]

            self.filepath = os.path.dirname(blend_filepath) +'/'+ modelname + self.filename_ext
        context.window_manager.fileselect_add(self)
        return {'RUNNING_MODAL'}
        
    def execute(self, context):
        keywords = self.as_keywords(ignore=("filter_glob","check_existing"))
        return save(self, context, self.data_layout, self.uv_mirror_y, keywords['filepath'])

def menu_func_export(self, context):
    self.layout.operator(ExportMODEL.bl_idname, text="Orc Model (.orcm)")

def register():
    bpy.utils.register_module(__name__)
    bpy.types.INFO_MT_file_export.append(menu_func_export)

def unregister():
    bpy.utils.unregister_module(__name__)
    bpy.types.INFO_MT_file_export.remove(menu_func_export)

if __name__ == "__main__":
    register()

def vert_calc_tang(va, vb, vc):
    # wektory w obj space
    Ao = Math.Vector(vb['pos']) - Math.Vector(va['pos'])
    Bo = Math.Vector(vc['pos']) - Math.Vector(va['pos'])
    # ich odpowiedniki w tex space
    At = Math.Vector(vb['uv0']) - Math.Vector(va['uv0'])
    Bt = Math.Vector(vc['uv0']) - Math.Vector(va['uv0'])

    # rozwiazujemy uklad rownan:
    # a At + b Bt = (0, 1)
    # c At + d Bt = (1, 0)

    #wspolczynniki dla bitangenta    
    detb = (Bt[1]*At[0] - Bt[0]*At[1])
    dett = (Bt[0]*At[1] - Bt[1]*At[0])
    if detb == 0 or dett == 0:
        return (1,0,0)
        
    a = -Bt[0] / detb
    b = At[0] / detb

    # wspolczynniki dla tangenta    
    c = -Bt[1] / dett
    d = At[1] / dett
    
    normal = Math.Vector(va['norm'])
    # obliczamy bitangent i ortognalizujemy grammem shmidtem z wekt.norm.
    bitangent = -(Ao*a + Bo*b);
    bitangent -= (bitangent.dot(normal)) * normal;

    tangent = Ao*c + Bo*d;
    tangent -= (tangent.dot(normal))*normal;

    tangent.normalize();
    bitangent.normalize();

    return ( tangent[0], tangent[1], tangent[2] )
    
def getBonesChain(bone, boneListOrder, boneMatricesByName, mtx, x, y, z):
    b = { }
    b['name'] = bone.name            
    
    if bone.parent:
        headTransformed = mtx * bone.head
        tailTransformed = mtx * bone.tail
        b['tail'] = (tailTransformed[0], tailTransformed[2], tailTransformed[1])
        b['head'] = (x + headTransformed[0], y + headTransformed[2], z + headTransformed[1])
    else:
        b['tail'] = (bone.tail[0] - bone.head[0], bone.tail[2] - bone.head[2], bone.tail[1] - bone.head[1])
        b['head'] = (x + bone.head[0], y + bone.head[2], z + bone.head[1])
        
    mtx = mtx * bone.matrix
    boneMatricesByName[bone.name] = mtx.copy()       
    
    b['chld'] = [boneChild.name for boneChild in bone.children]
    boneListOrder.append(b)
    for boneChild in bone.children:
        getBonesChain(boneChild, boneListOrder, boneMatricesByName, mtx.copy(), b['head'][0] + b['tail'][0], b['head'][1] + b['tail'][1], b['head'][2] + b['tail'][2])
        
        
def getBones(armature, bonesList, boneNames, boneMatrices):
    boneListOrder = []
    boneMatricesByName = { }
    for bone in armature.bones:
        if not (bone.parent):
            getBonesChain(bone, boneListOrder, boneMatricesByName, Math.Matrix().to_3x3(), 0, 0, 0)
    bid = 0
    for b in boneListOrder:
        print('Saving bone ', b['name'])    
        print('Head = ', b['head'])
        print('Tail = ', b['tail'])    
        print('Children = ' , b['chld'])
        bonesList.append(b)
        boneMatrices.append(boneMatricesByName[b['name']])
        boneNames[b['name']] = bid
        bid += 1    

def save(operator,context, data_layout, mirrory, filepath=""):    
    bones = []
    anims = []    
    skeletonName = "";
    compsizes = { 'pos':3,'norm':3,'tan':3,'uv0':2,'uv1':2,'uv2':2,'uv3':2,'bones':4,'weights':4}
    comps = data_layout.split(',')
    vFormat = [(comp, compsizes[comp]) for comp in comps ]
    collision2dByName = { }

    def uvMirrorY(uv):
        if mirrory:
            return 1.0 - uv
        else:
            return uv

    # zbieranie animacji i kosci
    for sel in bpy.context.selected_objects:
        if sel.type == 'ARMATURE':
            bonenames = {}
            boneMatrices = [ ]
            armature = bpy.data.armatures[sel.name]
            armatureob = bpy.data.objects[sel.name]
            skeletonName = sel.name
                        
            print('Saving skeleton ', sel.name)
            getBones(armature, bones, bonenames, boneMatrices)   
            
            for bone in bones:
                bone['chld'] = [bonenames[chld] for chld in bone['chld']]
            
            anims = {}
            for act in bpy.data.actions:
                anim = {}
                anim['name']=act.name
                anim['len']=act.frame_range[1]                              

                # zbieranie informacji o pozycjach klatek kluczowych
                # zakladajac, ze klatki pierwszej f-curve sa wszedzie
                kframepts = [kp.co[0] for kp in act.fcurves[0].keyframe_points]
                anim['frames'] = kframepts
                if anim['len'] != kframepts[-1]:
                    raise Exception('Animation ' + act.name + ': last frame is not a keyframe')
                tracks = [[{'loc': [0,0,0], 'rot': [1,0,0,0]} for t in kframepts] for b in bones]
                for fcurve in act.fcurves:
                    propname = fcurve.data_path.split('.')[-1]
                    namesplit = fcurve.data_path.split('"')
                    if len(namesplit) < 2: continue            
                    bonename = fcurve.data_path.split('"')[-2]
                    if bonename in bonenames:
                        boneid = bonenames[bonename]                    
                        for i in range(0,len(kframepts)):
                            val = fcurve.evaluate(kframepts[i])
                            if propname == 'location':                            
                                tracks[boneid][i]['loc'][fcurve.array_index] = val
                            if propname == 'rotation_quaternion':
                                tracks[boneid][i]['rot'][fcurve.array_index] = val                

                # konwertujemy dane do uczciwej bazy
                boneid = 0
                for track in tracks:
                    for kf in track:
                        locVec = Math.Vector((kf['loc'][0], kf['loc'][1], kf['loc'][2]))
                        locVec = boneMatrices[boneid] * locVec
                        kf['loc'] = [locVec[0], locVec[2], locVec[1]]
                        rotAxis = Math.Vector((kf['rot'][1], kf['rot'][2], kf['rot'][3]))                        
                        rotAxis = boneMatrices[boneid] * rotAxis
                        kf['rot'] = [-rotAxis[0], -rotAxis[2], -rotAxis[1], kf['rot'][0]]
                    boneid+=1
                    
                print('Saving animation ',  act.name)
                print('Keyframes count = ',  len(anim['frames']))
                print('Length = ', anim['len'])

                anim['tracks'] = tracks
                anims[anim['name']] = anim



    for sel in bpy.context.selected_objects:
        if sel.type == 'MESH':
            if sel.name[:6] == 'COL2D/':
                collision2d = { }                
                collision2dByName[sel.name[6:]] = collision2d
                collision2d["polygons"] = [ ]
                
                mesh = bpy.data.meshes[sel.name]
                for k in range(0, len(mesh.polygons)):
                    polygon2d = [ ]
                    for i in range(0, len(mesh.polygons[k].vertices)):
                        pos = mesh.vertices[mesh.polygons[k].vertices[i]].co
                        polygon2d.append([pos[0], pos[1]])
                    collision2d["polygons"].append(polygon2d)           
            
    for sel in bpy.context.selected_objects:
        if sel.type == 'MESH':
            if sel.name[:6] != 'COL2D/':
                mesh = bpy.data.meshes[sel.name]
                meshob = bpy.data.objects[sel.name]
                objectName = sel.name
                uvlayers = []
                vertsArr = []
                textures = []

                if len(bones)>0:
                    bonegroups = [g for g in meshob.vertex_groups if g.name in bonenames.keys()]  
                    bonegroupsids = [g.index for g in bonegroups] 

                for v in mesh.vertices:
                    vert = {}
                    vert['pos'] = (v.co[0], v.co[1], v.co[2]) 
                    vert['norm'] = (v.normal[0], v.normal[1], v.normal[2])
                    if len(bones)>0:
                        affbones = [g for g in v.groups if g.group in bonegroupsids]  
                        if len(affbones)>0:
                            sortbones = sorted(affbones, key=lambda g: g.weight)
                            vertBones = []
                            weightSum = 0
                            for i in range(1,min(len(sortbones)+1, 5)): 
                                if meshob.vertex_groups[sortbones[-i].group].name in bonenames:
                                    vertBones.append( (bonenames[meshob.vertex_groups[sortbones[-i].group].name],sortbones[-i].weight) )
                                    weightSum += sortbones[-i].weight
                            # normalizujemy wagi                        
                            vert['bones'] = [ ba[0] for ba in vertBones]
                            vert['weights'] = [ ba[1]/weightSum for ba in vertBones ]                        
                        else:
                            vert['bones'] = [ 0 , 0 , 0 , 0 ]
                            vert['weights'] = [ 0 , 0 , 0 ,0 ]
                            print('vertex without bon assignment')
                    vertsArr.append(vert)

                for uvlayer in mesh.uv_layers:
                    uvs = []
                    faceId = 0                
                    numFaces = len(uvlayer.data)//3
                    for uvId in range(0,numFaces):
                        uvs.append(( (uvlayer.data[uvId*3].uv[0], uvMirrorY(uvlayer.data[uvId*3].uv[1])),(uvlayer.data[uvId*3+1].uv[0],uvMirrorY(uvlayer.data[uvId*3+1].uv[1])),(uvlayer.data[uvId*3+2].uv[0],uvMirrorY(uvlayer.data[uvId*3+2].uv[1]))))
                    uvlayers.append(uvs)

                verts = []        
                for k in range(0, len(mesh.polygons)):
                    for i in range(0,3):
                        vert = {}            
                        for (name,v) in vertsArr[mesh.polygons[k].vertices[i]].items():
                            vert[name]=v
                        uvi = 0
                        for uv in uvlayers:
                            vert['uv'+str(uvi)]=uv[k][i]
                            uvi += 1

                        vert['mat']=meshob.data.materials[mesh.polygons[k].material_index].name
                        verts.append(vert)

                    if 'uv0' in verts[-3] and 'tan' in comps:
                        tan = vert_calc_tang(verts[-3], verts[-2], verts[-1])
                        verts[-3]['tan']=tan
                        verts[-2]['tan']=tan
                        verts[-1]['tan']=tan
                
                def get_vert_hash(v):
                    return "%s%s%s" % (v['pos'],v['norm'],v['uv0'] if 'uv0' in v else '')

                # budujemy tablice indeksowanych wierzcholkow
                vertmap = { }
                index = 0
                for v in verts:
                    if get_vert_hash(v) not in vertmap:
                        vertmap[get_vert_hash(v)] = (index,v)
                        index += 1


                # --- ZAPIS WIERZCHOLKOW ---
                # sortujemy wierzcholki wg. indeksu
                sortVerts = sorted(vertmap.values(), key=lambda v: v[0])
            
                # wypelniamy tablice wyjsciowa wierzcholkow danymi
                vertData = []
                boneAssign = []
                for (_,v) in sortVerts:            
                    if 'bones' in v:
                        boneAssign.append( list(zip(v['bones'], v['weights'])) )
                    for (name, size) in vFormat:
                        # przerabiamy wektory do bazy uzywanej w silniku
                        if size==3:
                            vertData.extend([v[name][0], v[name][2], v[name][1]])
                        else: 
                            for i in range(0,len(v[name])): vertData.append(v[name][i])
                            for i in range(len(v[name]), size): vertData.append(0)
                 
            # ZAPIS INDEKSOW
                matGroups = {}
                for i in range(0, len(verts)):
                    index = vertmap[get_vert_hash(verts[i])][0]
                    matGroups.setdefault(verts[i]['mat'], []).append(index)
                    
                print('Saving mesh ', sel.name)            
                print('Vertex count = ', len(vertmap.values()))
                print('Triangles count = ', len(mesh.polygons))
                print('Materials = ', matGroups.keys())

                if len(bones)>0:
                    pathdir = os.path.dirname(filepath)
                    outfile = open(pathdir+'/'+skeletonName+'.orcs', "wt")
                    outfile.write(json.dumps([skeletonName,bones,anims]))
                    outfile.close()
                    
                collisionData = { }
                if sel.name in collision2dByName:
                    collisionData["collision2d"] = collision2dByName[sel.name]
            
                outfile = open(filepath, "wt")
                outfile.write(json.dumps([objectName,vFormat,vertData,matGroups,skeletonName, collisionData]))
                outfile.close()


    return {'FINISHED'}
                
