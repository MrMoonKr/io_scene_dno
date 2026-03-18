#pragma comment "Dragon Nest .skn File Format Analyze"

#pragma endian little

import std.io; // std::format


// --------------------------------------------------------------------------

struct float2 { float x; float y; };
struct float3 { float x; float y; float z; };
struct float4 { float x; float y; float z; float w; };


// --------------------------------------------------------------------------

struct SKNName {
    char        m_String[256];

}[[name(SKNName_Name(this))]];

fn SKNName_Name( auto data ) {
    return std::format("{}",
        data.m_String
    );
};

struct SKNCountedString {
    u32         m_Length;
    char        m_String[m_Length];

}[[name(SKNCountedString_Name(this))]];

fn SKNCountedString_Name( auto data ) {
    return std::format("{}",
        data.m_String
    );
};

enum SKNMaterialPropertyType : u32 {
    Int             = 0x00 ,
    Float           = 0x01 ,
    Vector          = 0x02 ,
    Texture         = 0x03 ,
    None            = 0x04 ,
};

struct SKNMaterialProperty {
    SKNCountedString        m_Name;
    SKNMaterialPropertyType m_Type;

    if ( m_Type == SKNMaterialPropertyType::Int ) {
        s32             m_IntValue;
    }
    else if ( m_Type == SKNMaterialPropertyType::Float ) {
        float           m_FloatValue;
    }
    else if ( m_Type == SKNMaterialPropertyType::Vector ) {
        float4          m_VectorValue;
    }
    else if ( m_Type == SKNMaterialPropertyType::Texture ) {
        SKNCountedString    m_TextureValue;
    }
    else if ( m_Type == SKNMaterialPropertyType::None ) {
        //
    }
    else {
        //
    }

}[[name(SKNMaterialProperty_Name(this))]];

fn SKNMaterialProperty_Name( auto data ) {
    return std::format("{}",
        data.m_Name.m_String
    );
};

struct SKNMaterial {
    SKNName         m_Name;
    SKNName         m_Effect;
    float           m_Alpha;
    u32             m_AlphaBlend;
    char            m_Padding[512 - 8];

    u32             m_PropertyCount;
    if ( m_PropertyCount > 0 ) {
        SKNMaterialProperty m_Property[m_PropertyCount];
    }

}[[name(SKNMaterial_Name(this))]];

fn SKNMaterial_Name( auto data ) {
    return std::format("{} | Effect({}) | Props({})",
        data.m_Name.m_String ,
        data.m_Effect.m_String ,
        data.m_PropertyCount
    );
};

enum SKNFragOrder : u32 {
    Order_23041     = 0x00 ,
    Order_10423     = 0x01 ,
    Order_43012     = 0x02 ,
    Order_32140     = 0x03 ,
    Order_32401     = 0x04 ,
};

struct SKNHeader {
    SKNName         m_FourCC;           // 256
    SKNName         m_Name;             // 256 (total 512)

    u32             m_Version;          // 4
    u32             m_MaterialCount;    // 4
    u32             m_BodySize;         // 4
    SKNFragOrder    m_FragmentsOrder;  // 4

    char            m_Padding[496];     // to reach 1024
};

struct SKNFile {
    SKNHeader       m_Header [[name("m_Header")]];

    if ( m_Header.m_Version < 11 ) {
        if ( m_Header.m_MaterialCount > 0 ) {
            SKNMaterial m_Material[m_Header.m_MaterialCount];
        }
    }
    else if ( m_Header.m_BodySize > 0 ) {
        // version 11+ stores the material body in five shuffled fragments.
        // These blocks follow raw on-disk order from skn.py.
        u32 fragment_size = m_Header.m_BodySize / 5 / 2 * 2;
        u32 last_fragment_size = m_Header.m_BodySize - ( fragment_size * 4 );

        if ( m_Header.m_FragmentsOrder == SKNFragOrder::Order_23041 ) {
            u8  m_Fragment2[fragment_size]      [[name("Fragment[2]")]];
            u8  m_Fragment3[fragment_size]      [[name("Fragment[3]")]];
            u8  m_Fragment0[fragment_size]      [[name("Fragment[0]")]];
            u8  m_Fragment4[last_fragment_size] [[name("Fragment[4]")]];
            u8  m_Fragment1[fragment_size]      [[name("Fragment[1]")]];
        }
        else if ( m_Header.m_FragmentsOrder == SKNFragOrder::Order_10423 ) {
            u8  m_Fragment1[fragment_size]      [[name("Fragment[1]")]];
            u8  m_Fragment0[fragment_size]      [[name("Fragment[0]")]];
            u8  m_Fragment4[last_fragment_size] [[name("Fragment[4]")]];
            u8  m_Fragment2[fragment_size]      [[name("Fragment[2]")]];
            u8  m_Fragment3[fragment_size]      [[name("Fragment[3]")]];
        }
        else if ( m_Header.m_FragmentsOrder == SKNFragOrder::Order_43012 ) {
            u8  m_Fragment4[last_fragment_size] [[name("Fragment[4]")]];
            u8  m_Fragment3[fragment_size]      [[name("Fragment[3]")]];
            u8  m_Fragment0[fragment_size]      [[name("Fragment[0]")]];
            u8  m_Fragment1[fragment_size]      [[name("Fragment[1]")]];
            u8  m_Fragment2[fragment_size]      [[name("Fragment[2]")]];
        }
        else if ( m_Header.m_FragmentsOrder == SKNFragOrder::Order_32140 ) {
            u8  m_Fragment3[fragment_size]      [[name("Fragment[3]")]];
            u8  m_Fragment2[fragment_size]      [[name("Fragment[2]")]];
            u8  m_Fragment1[fragment_size]      [[name("Fragment[1]")]];
            u8  m_Fragment4[last_fragment_size] [[name("Fragment[4]")]];
            u8  m_Fragment0[fragment_size]      [[name("Fragment[0]")]];
        }
        else if ( m_Header.m_FragmentsOrder == SKNFragOrder::Order_32401 ) {
            u8  m_Fragment3[fragment_size]      [[name("Fragment[3]")]];
            u8  m_Fragment2[fragment_size]      [[name("Fragment[2]")]];
            u8  m_Fragment4[last_fragment_size] [[name("Fragment[4]")]];
            u8  m_Fragment0[fragment_size]      [[name("Fragment[0]")]];
            u8  m_Fragment1[fragment_size]      [[name("Fragment[1]")]];
        }
        else {
            u8  m_Body[m_Header.m_BodySize]     [[name("Body (Unknown Fragment Order)")]];
        }
    }

} [[name(SKNFile_Name(this))]];

fn SKNFile_Name( auto data ) {
    return std::format("Version({}) | Materials({}) | BodySize({})",
        data.m_Header.m_Version ,
        data.m_Header.m_MaterialCount ,
        data.m_Header.m_BodySize
    );
};


// --------------------------------------------------------------------------

SKNFile     g_File @ 0x00 ;