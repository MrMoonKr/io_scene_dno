#pragma comment "Dragon Nest .ani File Format Analyze"

#pragma endian little

import std.io; // std::format


// --------------------------------------------------------------------------

struct float3 { float x; float y; float z; };
struct float4 { float x; float y; float z; float w; };
struct short4 { s16 x; s16 y; s16 z; s16 w; };


// --------------------------------------------------------------------------

struct ANIName {
    char        m_String[256];

}[[name(ANIName_Name(this))]];

fn ANIName_Name( auto data ) {
    return std::format("{}",
        data.m_String
    );
};

struct ANIHeader {
    ANIName      m_FourCC;            // 256
    u32          m_Version;           // 4
    u32          m_BoneCount;         // 4
    u32          m_AnimationCount;    // 4
    char         m_Padding[756];      // to reach 1024
};

struct ANIAction {
    ANIName      m_Name;

}[[name(ANIAction_Name(this))]];

fn ANIAction_Name( auto data ) {
    return std::format("{}",
        data.m_Name.m_String
    );
};

struct ANIPositionKeyV10 {
    s32          m_Frame;
    float3       m_Value;

}[[name(ANIPositionKeyV10_Name(this))]];

fn ANIPositionKeyV10_Name( auto data ) {
    return std::format("Frame({}) | Pos({:.03},{:.03},{:.03})",
        data.m_Frame ,
        data.m_Value.x ,
        data.m_Value.y ,
        data.m_Value.z
    );
};

struct ANIRotationKeyV10 {
    s32          m_Frame;
    float4       m_Value;

}[[name(ANIRotationKeyV10_Name(this))]];

fn ANIRotationKeyV10_Name( auto data ) {
    return std::format("Frame({}) | Rot({:.03},{:.03},{:.03},{:.03})",
        data.m_Frame ,
        data.m_Value.x ,
        data.m_Value.y ,
        data.m_Value.z ,
        data.m_Value.w
    );
};

struct ANIScaleKeyV10 {
    s32          m_Frame;
    float3       m_Value;

}[[name(ANIScaleKeyV10_Name(this))]];

fn ANIScaleKeyV10_Name( auto data ) {
    return std::format("Frame({}) | Scale({:.03},{:.03},{:.03})",
        data.m_Frame ,
        data.m_Value.x ,
        data.m_Value.y ,
        data.m_Value.z
    );
};

struct ANIPositionKeyV11 {
    s16          m_Frame;
    float3       m_Value;

}[[name(ANIPositionKeyV11_Name(this))]];

fn ANIPositionKeyV11_Name( auto data ) {
    return std::format("Frame({}) | Pos({:.03},{:.03},{:.03})",
        data.m_Frame ,
        data.m_Value.x ,
        data.m_Value.y ,
        data.m_Value.z
    );
};

struct ANIRotationKeyV11 {
    s16          m_Frame;
    // Vector4D.read_short(): each component is stored as s16 and scaled by 2^-15.
    short4       m_Value;

}[[name(ANIRotationKeyV11_Name(this))]];

fn ANIRotationKeyV11_Name( auto data ) {
    return std::format("Frame({}) | RotShort({},{},{},{})",
        data.m_Frame ,
        data.m_Value.x ,
        data.m_Value.y ,
        data.m_Value.z ,
        data.m_Value.w
    );
};

struct ANIScaleKeyV11 {
    s16          m_Frame;
    float3       m_Value;

}[[name(ANIScaleKeyV11_Name(this))]];

fn ANIScaleKeyV11_Name( auto data ) {
    return std::format("Frame({}) | Scale({:.03},{:.03},{:.03})",
        data.m_Frame ,
        data.m_Value.x ,
        data.m_Value.y ,
        data.m_Value.z
    );
};

struct ANIAnimationV10 {
    float3       m_BaseLocation;
    float4       m_BaseRotation;
    float3       m_BaseScale;

    u32          m_LocationCount;
    if ( m_LocationCount > 0 ) {
        ANIPositionKeyV10 m_Location[m_LocationCount];
    }

    u32          m_RotationCount;
    if ( m_RotationCount > 0 ) {
        ANIRotationKeyV10 m_Rotation[m_RotationCount];
    }

    u32          m_ScaleCount;
    if ( m_ScaleCount > 0 ) {
        ANIScaleKeyV10 m_Scale[m_ScaleCount];
    }

}[[name(ANIAnimationV10_Name(this))]];

fn ANIAnimationV10_Name( auto data ) {
    return std::format("Loc({}) | Rot({}) | Scale({})",
        data.m_LocationCount ,
        data.m_RotationCount ,
        data.m_ScaleCount
    );
};

struct ANIAnimationV11 {
    float3       m_BaseLocation;
    float4       m_BaseRotation;
    float3       m_BaseScale;

    u32          m_LocationCount;
    if ( m_LocationCount > 0 ) {
        ANIPositionKeyV11 m_Location[m_LocationCount];
    }

    u32          m_RotationCount;
    if ( m_RotationCount > 0 ) {
        ANIRotationKeyV11 m_Rotation[m_RotationCount];
    }

    u32          m_ScaleCount;
    if ( m_ScaleCount > 0 ) {
        ANIScaleKeyV11 m_Scale[m_ScaleCount];
    }

}[[name(ANIAnimationV11_Name(this))]];

fn ANIAnimationV11_Name( auto data ) {
    return std::format("Loc({}) | Rot({}) | Scale({})",
        data.m_LocationCount ,
        data.m_RotationCount ,
        data.m_ScaleCount
    );
};

struct ANIBoneV10 {
    ANIName      m_Name;
    ANIName      m_ParentName;
    char         m_Padding[512];

    if ( parent.m_Header.m_AnimationCount > 0 ) {
        ANIAnimationV10 m_Animation[parent.m_Header.m_AnimationCount];
    }

}[[name(ANIBone_Name(this))]];

struct ANIBoneV11 {
    ANIName      m_Name;
    ANIName      m_ParentName;
    char         m_Padding[512];

    if ( parent.m_Header.m_AnimationCount > 0 ) {
        ANIAnimationV11 m_Animation[parent.m_Header.m_AnimationCount];
    }

}[[name(ANIBone_Name(this))]];

fn ANIBone_Name( auto data ) {
    return std::format("{} (Parent:{})",
        data.m_Name.m_String ,
        data.m_ParentName.m_String
    );
};

struct ANIFile {
    ANIHeader       m_Header ;

    if ( m_Header.m_AnimationCount > 0 ) {
        ANIAction   m_Actions[ m_Header.m_AnimationCount ] ;
        u32         m_ActionFrameCounts[ m_Header.m_AnimationCount ] ;
    }

    if ( m_Header.m_BoneCount > 0 ) {
        if ( m_Header.m_Version < 11 ) {
            ANIBoneV10 m_Bones[ m_Header.m_BoneCount ];
        }
        else {
            ANIBoneV11 m_Bones[ m_Header.m_BoneCount ];
        }
    }

}[[name(ANIFile_Name(this))]];

fn ANIFile_Name( auto data ) {
    return std::format("Version({}) | Bones({}) | Actions({})",
        data.m_Header.m_Version ,
        data.m_Header.m_BoneCount ,
        data.m_Header.m_AnimationCount
    );
};


// --------------------------------------------------------------------------

ANIFile     g_File @ 0x00 ;