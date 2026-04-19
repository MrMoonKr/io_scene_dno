from collections.abc import Iterable, Sequence

from bpy.types import Context, Node, Object
from mathutils import Euler, Matrix, Quaternion, Vector

ORIENTATION_MATRIX: Matrix = Matrix(((1.0, 0.0, 0.0, 0.0),
                                     (0.0, 0.0, 1.0, 0.0),
                                     (0.0, 1.0, 0.0, 0.0),
                                     (0.0, 0.0, 0.0, 1.0)))


def oriented_matrix( mat: Matrix ) -> Matrix:
    '''
        Dragon Nest -> Blender
        '''
    return ORIENTATION_MATRIX @ mat @ ORIENTATION_MATRIX


def unoriented_matrix( mat: Matrix ) -> Matrix:
    '''
        Blender -> Dragon Nest
        '''
    return ORIENTATION_MATRIX.inverted() @ mat @ ORIENTATION_MATRIX.inverted()


def translation_matrix( v: Vector | Sequence[float] ) -> Matrix:
    return Matrix.Translation( v )


def rotation_matrix( v: Quaternion | Euler ) -> Matrix:
    return v.to_matrix().to_4x4()


def scale_matrix( v: Vector | Sequence[float] ) -> Matrix:
    mat = Matrix.Identity(4)
    mat[0][0], mat[1][1], mat[2][2] = v[0], v[1], v[2]
    return mat


def get_active_armature_object( context: Context ) -> Object | None:
    arm_obj = context.object
    if not arm_obj:
        return

    if arm_obj.type == 'ARMATURE':
        return arm_obj

    arm_obj = arm_obj.parent
    if arm_obj and arm_obj.type == 'ARMATURE':
        return arm_obj


def get_armature_matrices( armature_object: Object ) -> dict[str, Matrix]:
    matrices: dict[str, Matrix] = {}
    for bone in armature_object.data.bones:
        matrices[bone.name] = bone.matrix_local @ scale_matrix(bone.dragon_nest.scale)
    return matrices


def find_material_node( nodes: Iterable[Node], node_type: str ) -> Node | None:
    return next((node for node in nodes if node.type == node_type), None)


def format_object_name( name: str | None, suffix: str = "Object" ) -> str:
    if not name:
        return "Unnamed " + suffix

    if "." in name:
        return name + ".001"

    return name


def extract_object_name( obj: Object ) -> str:
    name = obj.name

    if name.startswith("Unnamed "):
        return ""

    dot_pos = name.rfind(".")
    return name if dot_pos < 0 else name[:dot_pos]
