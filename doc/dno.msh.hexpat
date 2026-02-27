#pragma comment "Dragon Nest .msh File Format Analyze"

#pragma endian little

import std.io; // std::format


// --------------------------------------------------------------------------

struct float2 { float x; float y; };
struct float3 { float x; float y; float z; };
struct float4 { float x; float y; float z; float w; };


// --------------------------------------------------------------------------

struct DNName {
    char    m_String[256];
}[[name(DNName_Name(this))]];

fn DNName_Name( auto data ) {
    return std::format("{}",
        data.m_String 
    );
};

struct DNBone {
    char    m_Name[256];
    float4  m_Row1;
    float4  m_Row2;
    float4  m_Row3;
    float4  m_Row4;
}[[name(DNBone_Name(this))]];

fn DNBone_Name( auto data ) {
    return std::format("{} | Pos({:.01},{:.01},{:.01})" ,
        data.m_Name ,
        data.m_Row4.x ,
        data.m_Row4.y ,
        data.m_Row4.z 
    );
};

struct BoneIndices {
    s16     m_BoneIndices[4];
};

struct BoneWeights {
    float4  m_BoneWeights;
};

struct MSHHeader {
    DNName  m_Parent;           // 256
    DNName  m_Name;             // 256 (total 512)

    u32     m_VertexCount;      // 4
    u32     m_IndexCount;       // 4
    u32     m_ChannelCount;     // 4

    u8      m_UseStrip;         // 1
    u8      m_UsePhysique;      // 1
    u8      m_UseVertexColor;   // 1
    u8      m_Padding1;         // 1   (subtotal after flags = 528)

    char    m_Padding2[496];    // 528 + 496 = 1024
};

struct MSHMesh {

    MSHHeader m_Header [[name("Mesh Header")]];

    if ( m_Header.m_IndexCount > 0 ) {
         u16 m_IndexArray[ m_Header.m_IndexCount ] [[name("Indices")]];
    }

    if ( m_Header.m_VertexCount > 0 ) {
        float3 m_Positions[m_Header.m_VertexCount] [[name("Positions")]] ;
        float3 m_Normals[m_Header.m_VertexCount]   [[name("Normals")]] ;
        
        u32 c = m_Header.m_ChannelCount ;
        if ( c == 1 )
        {
            float2 m_UV1s[ m_Header.m_VertexCount ] [[name("UVs")]] ;
        }
        else if ( c == 2 )
        {
            float3 m_UV1s[ m_Header.m_VertexCount ] [[name("UVs")]] ;
            float2 m_UV2s[ m_Header.m_VertexCount ] [[name("UV1s")]] ;
        }
        else {
            //
        }
    }

    if ( m_Header.m_UseVertexColor == 1 ) {
        u32 m_Colors[ m_Header.m_VertexCount ] [[name("Vertex Colors")]] ;
    }

    if ( m_Header.m_UsePhysique == 1 ) {
        BoneIndices m_BoneIndices[m_Header.m_VertexCount] [[name("Bone Indices")]];
        BoneWeights m_BoneWeights[m_Header.m_VertexCount] [[name("Bone Weights")]];

        u32 m_BoneCount [[name("Mesh Bone Count")]];
        if (m_BoneCount > 0) {
            DNName m_BoneNames[m_BoneCount] [[name("Mesh Bone Names")]];
        }
    }
}[[name(MSHMesh_Name(this))]];

fn MSHMesh_Name( auto data ) {
    return std::format("{}({})",
        data.m_Header.m_Name.m_String ,
        data.m_Header.m_Parent.m_String 
    );
};

enum MSHColliderType : u32 {
    Box             = 0x00 ,
    Sphere          = 0x01 ,
    Capsule         = 0x02 ,
    Triangle        = 0x03 ,
    TriangleList    = 0x04 ,
};

struct MSHCollider {
    MSHColliderType m_Type;
    match ( m_Type ) {
        (MSHColliderType::Box): {
        }
        (MSHColliderType::Sphere): {
        }
        (MSHColliderType::Capsule): {
            float3  m_Origin;
            float3  m_Direction;
            float   m_Radius;
        }
        (MSHColliderType::Triangle|MSHColliderType::TriangleList): {
        }
    }
};


struct MSHDummy {
    DNName  m_Name ;
};

struct MSHFile {
    char    m_FourCC[256];  // 'Eternity Engine Mesh File 0.13'
    u32     m_Version;      // 13
    u32     m_MeshCount;
    u32     m_LodCount;     // 1
    u8      m_UVAni;
    u8      m_Zero[3];      // 0,0,0
    float3  m_Max;
    float3  m_Min;
    u32     m_BoneCount;
    u32     m_CollisionCount;
    u32     m_DummyCount;
    char    m_Padding[716]; // to reach 1024
    
    if ( m_BoneCount > 0 ) {
        DNBone  m_Bone[ m_BoneCount ] ;
    }
    
    if ( m_MeshCount > 0 ) {
        MSHMesh m_Mesh[ m_MeshCount ] ;
    }
    
    if ( m_CollisionCount > 0 ) {
        MSHCollider m_Collider[ m_CollisionCount ] ;
    }
    
    if ( m_DummyCount > 0 ) {
        MSHDummy m_Dummy ;
    }
    
} [[name(MSHFile_Name(this))]];

fn MSHFile_Name( auto data ) {
    return std::format("Version({}) | Meshes({}) | LODs({}) | Bones({})",
        data.m_Version ,
        data.m_MeshCount ,
        data.m_LodCount ,
        data.m_BoneCount  
        );
};


// --------------------------------------------------------------------------

MSHFile     g_File @ 0x00 ;