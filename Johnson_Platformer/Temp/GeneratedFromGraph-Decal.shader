Shader "Decal"
    {
        Properties
        {
            [NoScaleOffset]Base_Map("Base Map", 2D) = "white" {}
            [Normal][NoScaleOffset]Normal_Map("Normal Map", 2D) = "bump" {}
            [HideInInspector]_DrawOrder("Draw Order", Range(-50, 50)) = 0
            [HideInInspector][Enum(Depth Bias, 0, View Bias, 1)]_DecalMeshBiasType("DecalMesh BiasType", Float) = 0
            [HideInInspector]_DecalMeshDepthBias("DecalMesh DepthBias", Float) = 0
            [HideInInspector]_DecalMeshViewBias("DecalMesh ViewBias", Float) = 0
            [HideInInspector][NoScaleOffset]unity_Lightmaps("unity_Lightmaps", 2DArray) = "" {}
            [HideInInspector][NoScaleOffset]unity_LightmapsInd("unity_LightmapsInd", 2DArray) = "" {}
            [HideInInspector][NoScaleOffset]unity_ShadowMasks("unity_ShadowMasks", 2DArray) = "" {}
        }
        SubShader
        {
            Tags
            {
                "RenderPipeline"="UniversalPipeline"
                // RenderType: <None>
                "PreviewType"="Plane"
                // Queue: <None>
                "ShaderGraphShader"="true"
                "ShaderGraphTargetId"=""
            }
            Pass
            { 
                Name "DBufferProjector"
                Tags 
                { 
                    "LightMode" = "DBufferProjector"
                }
            
                // Render State
                Cull Front
                Blend 0 SrcAlpha OneMinusSrcAlpha, Zero OneMinusSrcAlpha
                Blend 1 SrcAlpha OneMinusSrcAlpha, Zero OneMinusSrcAlpha
                Blend 2 SrcAlpha OneMinusSrcAlpha, Zero OneMinusSrcAlpha
                ZTest Greater
                ZWrite Off
                ColorMask RGBA
                ColorMask RGBA 1
                ColorMask 0 2
            
                // Debug
                // <None>
            
                // --------------------------------------------------
                // Pass
            
                HLSLPROGRAM
            
                // Pragmas
                #pragma target 3.5
                #pragma vertex Vert
                #pragma fragment Frag
                #pragma multi_compile_instancing
            
                // Keywords
                #pragma multi_compile _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
                // GraphKeywords: <None>
            
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
            
                // Defines
                #define ATTRIBUTES_NEED_TEXCOORD0
                #define VARYINGS_NEED_TEXCOORD0
                
                #define HAVE_MESH_MODIFICATION
            
            
                #define SHADERPASS SHADERPASS_DBUFFER_PROJECTOR
                #define _MATERIAL_AFFECTS_ALBEDO 1
                #define _MATERIAL_AFFECTS_NORMAL 1
                #define _MATERIAL_AFFECTS_NORMAL_BLEND 1
            
                // HybridV1InjectedBuiltinProperties: <None>
            
                // -- Properties used by ScenePickingPass
                #ifdef SCENEPICKINGPASS
                float4 _SelectionID;
                #endif
            
                // Includes
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DecalInput.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderVariablesDecal.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
            
                // --------------------------------------------------
                // Structs and Packing
            
                struct Attributes
                {
                     float3 positionOS : POSITION;
                     float4 uv0 : TEXCOORD0;
                    #if UNITY_ANY_INSTANCING_ENABLED
                     uint instanceID : INSTANCEID_SEMANTIC;
                    #endif
                };
                struct Varyings
                {
                     float4 positionCS : SV_POSITION;
                     float4 texCoord0;
                    #if UNITY_ANY_INSTANCING_ENABLED
                     uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };
                struct SurfaceDescriptionInputs
                {
                     float3 TangentSpaceNormal;
                     float4 uv0;
                };
                struct VertexDescriptionInputs
                {
                };
                struct PackedVaryings
                {
                     float4 positionCS : SV_POSITION;
                     float4 interp0 : INTERP0;
                    #if UNITY_ANY_INSTANCING_ENABLED
                     uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };
            
                PackedVaryings PackVaryings (Varyings input)
                {
                    PackedVaryings output;
                    ZERO_INITIALIZE(PackedVaryings, output);
                    output.positionCS = input.positionCS;
                    output.interp0.xyzw =  input.texCoord0;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }
                
                Varyings UnpackVaryings (PackedVaryings input)
                {
                    Varyings output;
                    output.positionCS = input.positionCS;
                    output.texCoord0 = input.interp0.xyzw;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }
                
            
                // --------------------------------------------------
                // Graph
            
                // Graph Properties
                CBUFFER_START(UnityPerMaterial)
                float4 Base_Map_TexelSize;
                float4 Normal_Map_TexelSize;
                float _DrawOrder;
                float _DecalMeshBiasType;
                float _DecalMeshDepthBias;
                float _DecalMeshViewBias;
                CBUFFER_END
                
                // Object and Global properties
                SAMPLER(SamplerState_Linear_Repeat);
                TEXTURE2D(Base_Map);
                SAMPLER(samplerBase_Map);
                TEXTURE2D(Normal_Map);
                SAMPLER(samplerNormal_Map);
            
                // Graph Functions
                // GraphFunctions: <None>
            
                // Graph Vertex
                struct VertexDescription
                {
                };
                
                VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                {
                    VertexDescription description = (VertexDescription)0;
                    return description;
                }
                
                // Graph Pixel
                struct SurfaceDescription
                {
                    float3 BaseColor;
                    float Alpha;
                    float3 NormalTS;
                    float NormalAlpha;
                };
                
                SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                {
                    SurfaceDescription surface = (SurfaceDescription)0;
                    UnityTexture2D _Property_9f1059a7a93a46ccab349515214f3ed2_Out_0 = UnityBuildTexture2DStructNoScale(Base_Map);
                    float4 _SampleTexture2D_7388a7ddbf6648ec92c3bb54ed055048_RGBA_0 = SAMPLE_TEXTURE2D(_Property_9f1059a7a93a46ccab349515214f3ed2_Out_0.tex, _Property_9f1059a7a93a46ccab349515214f3ed2_Out_0.samplerstate, _Property_9f1059a7a93a46ccab349515214f3ed2_Out_0.GetTransformedUV(IN.uv0.xy));
                    float _SampleTexture2D_7388a7ddbf6648ec92c3bb54ed055048_R_4 = _SampleTexture2D_7388a7ddbf6648ec92c3bb54ed055048_RGBA_0.r;
                    float _SampleTexture2D_7388a7ddbf6648ec92c3bb54ed055048_G_5 = _SampleTexture2D_7388a7ddbf6648ec92c3bb54ed055048_RGBA_0.g;
                    float _SampleTexture2D_7388a7ddbf6648ec92c3bb54ed055048_B_6 = _SampleTexture2D_7388a7ddbf6648ec92c3bb54ed055048_RGBA_0.b;
                    float _SampleTexture2D_7388a7ddbf6648ec92c3bb54ed055048_A_7 = _SampleTexture2D_7388a7ddbf6648ec92c3bb54ed055048_RGBA_0.a;
                    UnityTexture2D _Property_360e6833e8d64d75827ab98987b2b545_Out_0 = UnityBuildTexture2DStructNoScale(Normal_Map);
                    float4 _SampleTexture2D_1300b7cb738f4b18927411750039acd2_RGBA_0 = SAMPLE_TEXTURE2D(_Property_360e6833e8d64d75827ab98987b2b545_Out_0.tex, _Property_360e6833e8d64d75827ab98987b2b545_Out_0.samplerstate, _Property_360e6833e8d64d75827ab98987b2b545_Out_0.GetTransformedUV(IN.uv0.xy));
                    float _SampleTexture2D_1300b7cb738f4b18927411750039acd2_R_4 = _SampleTexture2D_1300b7cb738f4b18927411750039acd2_RGBA_0.r;
                    float _SampleTexture2D_1300b7cb738f4b18927411750039acd2_G_5 = _SampleTexture2D_1300b7cb738f4b18927411750039acd2_RGBA_0.g;
                    float _SampleTexture2D_1300b7cb738f4b18927411750039acd2_B_6 = _SampleTexture2D_1300b7cb738f4b18927411750039acd2_RGBA_0.b;
                    float _SampleTexture2D_1300b7cb738f4b18927411750039acd2_A_7 = _SampleTexture2D_1300b7cb738f4b18927411750039acd2_RGBA_0.a;
                    float _Float_8d7a8de17c23469e9a65a11b77cc9886_Out_0 = 0.63;
                    surface.BaseColor = (_SampleTexture2D_7388a7ddbf6648ec92c3bb54ed055048_RGBA_0.xyz);
                    surface.Alpha = _SampleTexture2D_7388a7ddbf6648ec92c3bb54ed055048_A_7;
                    surface.NormalTS = (_SampleTexture2D_1300b7cb738f4b18927411750039acd2_RGBA_0.xyz);
                    surface.NormalAlpha = _Float_8d7a8de17c23469e9a65a11b77cc9886_Out_0;
                    return surface;
                }
            
                // --------------------------------------------------
                // Build Graph Inputs
            
                
            //     $features.graphVertex:  $include("VertexAnimation.template.hlsl")
            //                                       ^ ERROR: $include cannot find file : VertexAnimation.template.hlsl. Looked into:
            // Packages/com.unity.shadergraph/Editor/Generation/Templates
            
                
            //     $features.graphPixel:   $include("SharedCode.template.hlsl")
            //                                       ^ ERROR: $include cannot find file : SharedCode.template.hlsl. Looked into:
            // Packages/com.unity.shadergraph/Editor/Generation/Templates
            
                SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                {
                    SurfaceDescriptionInputs output;
                    ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
                
                    /* WARNING: $splice Could not find named fragment 'CustomInterpolatorCopyToSDI' */
                
                
                
                    output.TangentSpaceNormal =                         float3(0.0f, 0.0f, 1.0f);
                
                
                    output.uv0 =                                        input.texCoord0;
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN                output.FaceSign =                                   IS_FRONT_VFACE(input.cullFace, true, false);
                #else
                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                #endif
                #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                
                    return output;
                }
                
            
                // --------------------------------------------------
                // Build Surface Data
            
                uint2 ComputeFadeMaskSeed(uint2 positionSS)
                {
                    uint2 fadeMaskSeed;
            
                    // Can't use the view direction, it is the same across the entire screen.
                    fadeMaskSeed = positionSS;
            
                    return fadeMaskSeed;
                }
            
                void GetSurfaceData(Varyings input, half3 viewDirectioWS, uint2 positionSS, float angleFadeFactor, out DecalSurfaceData surfaceData)
                {
                    #if (SHADERPASS == SHADERPASS_DBUFFER_PROJECTOR) || (SHADERPASS == SHADERPASS_FORWARD_EMISSIVE_PROJECTOR) || (SHADERPASS == SHADERPASS_DECAL_SCREEN_SPACE_PROJECTOR) || (SHADERPASS == SHADERPASS_DECAL_GBUFFER_PROJECTOR)
                        half4x4 normalToWorld = UNITY_ACCESS_INSTANCED_PROP(Decal, _NormalToWorld);
                        half fadeFactor = clamp(normalToWorld[0][3], 0.0f, 1.0f) * angleFadeFactor;
                        float2 scale = float2(normalToWorld[3][0], normalToWorld[3][1]);
                        float2 offset = float2(normalToWorld[3][2], normalToWorld[3][3]);
                        input.texCoord0.xy = input.texCoord0.xy * scale + offset;
                    #else
                        #ifdef LOD_FADE_CROSSFADE // enable dithering LOD transition if user select CrossFade transition in LOD group
                            LODDitheringTransition(ComputeFadeMaskSeed(positionSS), unity_LODFade.x);
                        #endif
            
                        half fadeFactor = half(1.0);
                    #endif
            
                    SurfaceDescriptionInputs surfaceDescriptionInputs = BuildSurfaceDescriptionInputs(input);
                    SurfaceDescription surfaceDescription = SurfaceDescriptionFunction(surfaceDescriptionInputs);
            
                    // setup defaults -- these are used if the graph doesn't output a value
                    ZERO_INITIALIZE(DecalSurfaceData, surfaceData);
                    surfaceData.occlusion = half(1.0);
                    surfaceData.smoothness = half(0);
            
                    #ifdef _MATERIAL_AFFECTS_NORMAL
                        surfaceData.normalWS.w = half(1.0);
                    #else
                        surfaceData.normalWS.w = half(0.0);
                    #endif
            
            
                    // copy across graph values, if defined
                    surfaceData.baseColor.xyz = half3(surfaceDescription.BaseColor);
                    surfaceData.baseColor.w = half(surfaceDescription.Alpha * fadeFactor);
            
                    #if (SHADERPASS == SHADERPASS_DBUFFER_PROJECTOR) || (SHADERPASS == SHADERPASS_DECAL_SCREEN_SPACE_PROJECTOR) || (SHADERPASS == SHADERPASS_DECAL_GBUFFER_PROJECTOR)
                        #if defined(_MATERIAL_AFFECTS_NORMAL)
                            surfaceData.normalWS.xyz = mul((half3x3)normalToWorld, surfaceDescription.NormalTS.xyz);
                        #else
                            surfaceData.normalWS.xyz = normalToWorld[2].xyz;
                        #endif
                    #elif (SHADERPASS == SHADERPASS_DBUFFER_MESH) || (SHADERPASS == SHADERPASS_DECAL_SCREEN_SPACE_MESH) || (SHADERPASS == SHADERPASS_DECAL_GBUFFER_MESH)
                        #if defined(_MATERIAL_AFFECTS_NORMAL)
                            float sgn = input.tangentWS.w;      // should be either +1 or -1
                            float3 bitangent = sgn * cross(input.normalWS.xyz, input.tangentWS.xyz);
                            half3x3 tangentToWorld = half3x3(input.tangentWS.xyz, bitangent.xyz, input.normalWS.xyz);
            
                            // We need to normalize as we use mikkt tangent space and this is expected (tangent space is not normalize)
                            surfaceData.normalWS.xyz = normalize(TransformTangentToWorld(surfaceDescription.NormalTS, tangentToWorld));
                        #else
                            surfaceData.normalWS.xyz = half3(input.normalWS); // Default to vertex normal
                        #endif
                    #endif
            
                    surfaceData.normalWS.w = surfaceDescription.NormalAlpha * fadeFactor;
            
                    // In case of Smoothness / AO / Metal, all the three are always computed but color mask can change
                }
            
                // --------------------------------------------------
                // Main
            
                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPassDecal.hlsl"
            
                ENDHLSL
            }
            Pass
            { 
                Name "DecalScreenSpaceProjector"
                Tags 
                { 
                    "LightMode" = "DecalScreenSpaceProjector"
                }
            
                // Render State
                Cull Front
                Blend SrcAlpha OneMinusSrcAlpha
                ZTest Greater
                ZWrite Off
            
                // Debug
                // <None>
            
                // --------------------------------------------------
                // Pass
            
                HLSLPROGRAM
            
                // Pragmas
                #pragma target 2.5
                #pragma vertex Vert
                #pragma fragment Frag
                #pragma multi_compile_instancing
                #pragma multi_compile_fog
            
                // Keywords
                #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
                #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
                #pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS
                #pragma multi_compile _ _SHADOWS_SOFT
                #pragma multi_compile _ _CLUSTERED_RENDERING
                #pragma multi_compile _DECAL_NORMAL_BLEND_LOW _DECAL_NORMAL_BLEND_MEDIUM _DECAL_NORMAL_BLEND_HIGH
                // GraphKeywords: <None>
            
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
            
                // Defines
                #define ATTRIBUTES_NEED_NORMAL
                #define ATTRIBUTES_NEED_TEXCOORD0
                #define VARYINGS_NEED_NORMAL_WS
                #define VARYINGS_NEED_VIEWDIRECTION_WS
                #define VARYINGS_NEED_TEXCOORD0
                #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                #define VARYINGS_NEED_SH
                #define VARYINGS_NEED_STATIC_LIGHTMAP_UV
                #define VARYINGS_NEED_DYNAMIC_LIGHTMAP_UV
                
                #define HAVE_MESH_MODIFICATION
            
            
                #define SHADERPASS SHADERPASS_DECAL_SCREEN_SPACE_PROJECTOR
                #define _MATERIAL_AFFECTS_ALBEDO 1
                #define _MATERIAL_AFFECTS_NORMAL 1
                #define _MATERIAL_AFFECTS_NORMAL_BLEND 1
            
                // HybridV1InjectedBuiltinProperties: <None>
            
                // -- Properties used by ScenePickingPass
                #ifdef SCENEPICKINGPASS
                float4 _SelectionID;
                #endif
            
                // Includes
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DecalInput.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderVariablesDecal.hlsl"
            
                // --------------------------------------------------
                // Structs and Packing
            
                struct Attributes
                {
                     float3 positionOS : POSITION;
                     float3 normalOS : NORMAL;
                     float4 uv0 : TEXCOORD0;
                    #if UNITY_ANY_INSTANCING_ENABLED
                     uint instanceID : INSTANCEID_SEMANTIC;
                    #endif
                };
                struct Varyings
                {
                     float4 positionCS : SV_POSITION;
                     float3 normalWS;
                     float4 texCoord0;
                     float3 viewDirectionWS;
                    #if defined(LIGHTMAP_ON)
                     float2 staticLightmapUV;
                    #endif
                    #if defined(DYNAMICLIGHTMAP_ON)
                     float2 dynamicLightmapUV;
                    #endif
                    #if !defined(LIGHTMAP_ON)
                     float3 sh;
                    #endif
                     float4 fogFactorAndVertexLight;
                    #if UNITY_ANY_INSTANCING_ENABLED
                     uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };
                struct SurfaceDescriptionInputs
                {
                     float3 TangentSpaceNormal;
                     float4 uv0;
                };
                struct VertexDescriptionInputs
                {
                };
                struct PackedVaryings
                {
                     float4 positionCS : SV_POSITION;
                     float3 interp0 : INTERP0;
                     float4 interp1 : INTERP1;
                     float3 interp2 : INTERP2;
                     float2 interp3 : INTERP3;
                     float2 interp4 : INTERP4;
                     float3 interp5 : INTERP5;
                     float4 interp6 : INTERP6;
                    #if UNITY_ANY_INSTANCING_ENABLED
                     uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };
            
                PackedVaryings PackVaryings (Varyings input)
                {
                    PackedVaryings output;
                    ZERO_INITIALIZE(PackedVaryings, output);
                    output.positionCS = input.positionCS;
                    output.interp0.xyz =  input.normalWS;
                    output.interp1.xyzw =  input.texCoord0;
                    output.interp2.xyz =  input.viewDirectionWS;
                    #if defined(LIGHTMAP_ON)
                    output.interp3.xy =  input.staticLightmapUV;
                    #endif
                    #if defined(DYNAMICLIGHTMAP_ON)
                    output.interp4.xy =  input.dynamicLightmapUV;
                    #endif
                    #if !defined(LIGHTMAP_ON)
                    output.interp5.xyz =  input.sh;
                    #endif
                    output.interp6.xyzw =  input.fogFactorAndVertexLight;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }
                
                Varyings UnpackVaryings (PackedVaryings input)
                {
                    Varyings output;
                    output.positionCS = input.positionCS;
                    output.normalWS = input.interp0.xyz;
                    output.texCoord0 = input.interp1.xyzw;
                    output.viewDirectionWS = input.interp2.xyz;
                    #if defined(LIGHTMAP_ON)
                    output.staticLightmapUV = input.interp3.xy;
                    #endif
                    #if defined(DYNAMICLIGHTMAP_ON)
                    output.dynamicLightmapUV = input.interp4.xy;
                    #endif
                    #if !defined(LIGHTMAP_ON)
                    output.sh = input.interp5.xyz;
                    #endif
                    output.fogFactorAndVertexLight = input.interp6.xyzw;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }
                
            
                // --------------------------------------------------
                // Graph
            
                // Graph Properties
                CBUFFER_START(UnityPerMaterial)
                float4 Base_Map_TexelSize;
                float4 Normal_Map_TexelSize;
                float _DrawOrder;
                float _DecalMeshBiasType;
                float _DecalMeshDepthBias;
                float _DecalMeshViewBias;
                CBUFFER_END
                
                // Object and Global properties
                SAMPLER(SamplerState_Linear_Repeat);
                TEXTURE2D(Base_Map);
                SAMPLER(samplerBase_Map);
                TEXTURE2D(Normal_Map);
                SAMPLER(samplerNormal_Map);
            
                // Graph Functions
                // GraphFunctions: <None>
            
                // Graph Vertex
                struct VertexDescription
                {
                };
                
                VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                {
                    VertexDescription description = (VertexDescription)0;
                    return description;
                }
                
                // Graph Pixel
                struct SurfaceDescription
                {
                    float3 BaseColor;
                    float Alpha;
                    float3 NormalTS;
                    float NormalAlpha;
                };
                
                SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                {
                    SurfaceDescription surface = (SurfaceDescription)0;
                    UnityTexture2D _Property_9f1059a7a93a46ccab349515214f3ed2_Out_0 = UnityBuildTexture2DStructNoScale(Base_Map);
                    float4 _SampleTexture2D_7388a7ddbf6648ec92c3bb54ed055048_RGBA_0 = SAMPLE_TEXTURE2D(_Property_9f1059a7a93a46ccab349515214f3ed2_Out_0.tex, _Property_9f1059a7a93a46ccab349515214f3ed2_Out_0.samplerstate, _Property_9f1059a7a93a46ccab349515214f3ed2_Out_0.GetTransformedUV(IN.uv0.xy));
                    float _SampleTexture2D_7388a7ddbf6648ec92c3bb54ed055048_R_4 = _SampleTexture2D_7388a7ddbf6648ec92c3bb54ed055048_RGBA_0.r;
                    float _SampleTexture2D_7388a7ddbf6648ec92c3bb54ed055048_G_5 = _SampleTexture2D_7388a7ddbf6648ec92c3bb54ed055048_RGBA_0.g;
                    float _SampleTexture2D_7388a7ddbf6648ec92c3bb54ed055048_B_6 = _SampleTexture2D_7388a7ddbf6648ec92c3bb54ed055048_RGBA_0.b;
                    float _SampleTexture2D_7388a7ddbf6648ec92c3bb54ed055048_A_7 = _SampleTexture2D_7388a7ddbf6648ec92c3bb54ed055048_RGBA_0.a;
                    UnityTexture2D _Property_360e6833e8d64d75827ab98987b2b545_Out_0 = UnityBuildTexture2DStructNoScale(Normal_Map);
                    float4 _SampleTexture2D_1300b7cb738f4b18927411750039acd2_RGBA_0 = SAMPLE_TEXTURE2D(_Property_360e6833e8d64d75827ab98987b2b545_Out_0.tex, _Property_360e6833e8d64d75827ab98987b2b545_Out_0.samplerstate, _Property_360e6833e8d64d75827ab98987b2b545_Out_0.GetTransformedUV(IN.uv0.xy));
                    float _SampleTexture2D_1300b7cb738f4b18927411750039acd2_R_4 = _SampleTexture2D_1300b7cb738f4b18927411750039acd2_RGBA_0.r;
                    float _SampleTexture2D_1300b7cb738f4b18927411750039acd2_G_5 = _SampleTexture2D_1300b7cb738f4b18927411750039acd2_RGBA_0.g;
                    float _SampleTexture2D_1300b7cb738f4b18927411750039acd2_B_6 = _SampleTexture2D_1300b7cb738f4b18927411750039acd2_RGBA_0.b;
                    float _SampleTexture2D_1300b7cb738f4b18927411750039acd2_A_7 = _SampleTexture2D_1300b7cb738f4b18927411750039acd2_RGBA_0.a;
                    float _Float_8d7a8de17c23469e9a65a11b77cc9886_Out_0 = 0.63;
                    surface.BaseColor = (_SampleTexture2D_7388a7ddbf6648ec92c3bb54ed055048_RGBA_0.xyz);
                    surface.Alpha = _SampleTexture2D_7388a7ddbf6648ec92c3bb54ed055048_A_7;
                    surface.NormalTS = (_SampleTexture2D_1300b7cb738f4b18927411750039acd2_RGBA_0.xyz);
                    surface.NormalAlpha = _Float_8d7a8de17c23469e9a65a11b77cc9886_Out_0;
                    return surface;
                }
            
                // --------------------------------------------------
                // Build Graph Inputs
            
                
            //     $features.graphVertex:  $include("VertexAnimation.template.hlsl")
            //                                       ^ ERROR: $include cannot find file : VertexAnimation.template.hlsl. Looked into:
            // Packages/com.unity.shadergraph/Editor/Generation/Templates
            
                
            //     $features.graphPixel:   $include("SharedCode.template.hlsl")
            //                                       ^ ERROR: $include cannot find file : SharedCode.template.hlsl. Looked into:
            // Packages/com.unity.shadergraph/Editor/Generation/Templates
            
                SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                {
                    SurfaceDescriptionInputs output;
                    ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
                
                    /* WARNING: $splice Could not find named fragment 'CustomInterpolatorCopyToSDI' */
                
                
                
                    output.TangentSpaceNormal =                         float3(0.0f, 0.0f, 1.0f);
                
                
                    output.uv0 =                                        input.texCoord0;
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN                output.FaceSign =                                   IS_FRONT_VFACE(input.cullFace, true, false);
                #else
                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                #endif
                #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                
                    return output;
                }
                
            
                // --------------------------------------------------
                // Build Surface Data
            
                uint2 ComputeFadeMaskSeed(uint2 positionSS)
                {
                    uint2 fadeMaskSeed;
            
                    // Can't use the view direction, it is the same across the entire screen.
                    fadeMaskSeed = positionSS;
            
                    return fadeMaskSeed;
                }
            
                void GetSurfaceData(Varyings input, half3 viewDirectioWS, uint2 positionSS, float angleFadeFactor, out DecalSurfaceData surfaceData)
                {
                    #if (SHADERPASS == SHADERPASS_DBUFFER_PROJECTOR) || (SHADERPASS == SHADERPASS_FORWARD_EMISSIVE_PROJECTOR) || (SHADERPASS == SHADERPASS_DECAL_SCREEN_SPACE_PROJECTOR) || (SHADERPASS == SHADERPASS_DECAL_GBUFFER_PROJECTOR)
                        half4x4 normalToWorld = UNITY_ACCESS_INSTANCED_PROP(Decal, _NormalToWorld);
                        half fadeFactor = clamp(normalToWorld[0][3], 0.0f, 1.0f) * angleFadeFactor;
                        float2 scale = float2(normalToWorld[3][0], normalToWorld[3][1]);
                        float2 offset = float2(normalToWorld[3][2], normalToWorld[3][3]);
                        input.texCoord0.xy = input.texCoord0.xy * scale + offset;
                    #else
                        #ifdef LOD_FADE_CROSSFADE // enable dithering LOD transition if user select CrossFade transition in LOD group
                            LODDitheringTransition(ComputeFadeMaskSeed(positionSS), unity_LODFade.x);
                        #endif
            
                        half fadeFactor = half(1.0);
                    #endif
            
                    SurfaceDescriptionInputs surfaceDescriptionInputs = BuildSurfaceDescriptionInputs(input);
                    SurfaceDescription surfaceDescription = SurfaceDescriptionFunction(surfaceDescriptionInputs);
            
                    // setup defaults -- these are used if the graph doesn't output a value
                    ZERO_INITIALIZE(DecalSurfaceData, surfaceData);
                    surfaceData.occlusion = half(1.0);
                    surfaceData.smoothness = half(0);
            
                    #ifdef _MATERIAL_AFFECTS_NORMAL
                        surfaceData.normalWS.w = half(1.0);
                    #else
                        surfaceData.normalWS.w = half(0.0);
                    #endif
            
            
                    // copy across graph values, if defined
                    surfaceData.baseColor.xyz = half3(surfaceDescription.BaseColor);
                    surfaceData.baseColor.w = half(surfaceDescription.Alpha * fadeFactor);
            
                    #if (SHADERPASS == SHADERPASS_DBUFFER_PROJECTOR) || (SHADERPASS == SHADERPASS_DECAL_SCREEN_SPACE_PROJECTOR) || (SHADERPASS == SHADERPASS_DECAL_GBUFFER_PROJECTOR)
                        #if defined(_MATERIAL_AFFECTS_NORMAL)
                            surfaceData.normalWS.xyz = mul((half3x3)normalToWorld, surfaceDescription.NormalTS.xyz);
                        #else
                            surfaceData.normalWS.xyz = normalToWorld[2].xyz;
                        #endif
                    #elif (SHADERPASS == SHADERPASS_DBUFFER_MESH) || (SHADERPASS == SHADERPASS_DECAL_SCREEN_SPACE_MESH) || (SHADERPASS == SHADERPASS_DECAL_GBUFFER_MESH)
                        #if defined(_MATERIAL_AFFECTS_NORMAL)
                            float sgn = input.tangentWS.w;      // should be either +1 or -1
                            float3 bitangent = sgn * cross(input.normalWS.xyz, input.tangentWS.xyz);
                            half3x3 tangentToWorld = half3x3(input.tangentWS.xyz, bitangent.xyz, input.normalWS.xyz);
            
                            // We need to normalize as we use mikkt tangent space and this is expected (tangent space is not normalize)
                            surfaceData.normalWS.xyz = normalize(TransformTangentToWorld(surfaceDescription.NormalTS, tangentToWorld));
                        #else
                            surfaceData.normalWS.xyz = half3(input.normalWS); // Default to vertex normal
                        #endif
                    #endif
            
                    surfaceData.normalWS.w = surfaceDescription.NormalAlpha * fadeFactor;
            
                    // In case of Smoothness / AO / Metal, all the three are always computed but color mask can change
                }
            
                // --------------------------------------------------
                // Main
            
                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPassDecal.hlsl"
            
                ENDHLSL
            }
            Pass
            { 
                Name "DecalGBufferProjector"
                Tags 
                { 
                    "LightMode" = "DecalGBufferProjector"
                }
            
                // Render State
                Cull Front
                Blend 0 SrcAlpha OneMinusSrcAlpha
                Blend 1 SrcAlpha OneMinusSrcAlpha
                Blend 2 SrcAlpha OneMinusSrcAlpha
                Blend 3 SrcAlpha OneMinusSrcAlpha
                ZTest Greater
                ZWrite Off
                ColorMask RGB
                ColorMask 0 1
                ColorMask RGB 2
                ColorMask RGB 3
            
                // Debug
                // <None>
            
                // --------------------------------------------------
                // Pass
            
                HLSLPROGRAM
            
                // Pragmas
                #pragma target 3.5
                #pragma vertex Vert
                #pragma fragment Frag
                #pragma multi_compile_instancing
                #pragma multi_compile_fog
            
                // Keywords
                #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
                #pragma multi_compile _ _SHADOWS_SOFT
                #pragma multi_compile _DECAL_NORMAL_BLEND_LOW _DECAL_NORMAL_BLEND_MEDIUM _DECAL_NORMAL_BLEND_HIGH
                #pragma multi_compile _ _GBUFFER_NORMALS_OCT
                // GraphKeywords: <None>
            
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
            
                // Defines
                #define ATTRIBUTES_NEED_NORMAL
                #define ATTRIBUTES_NEED_TEXCOORD0
                #define VARYINGS_NEED_NORMAL_WS
                #define VARYINGS_NEED_VIEWDIRECTION_WS
                #define VARYINGS_NEED_TEXCOORD0
                #define VARYINGS_NEED_SH
                #define VARYINGS_NEED_STATIC_LIGHTMAP_UV
                #define VARYINGS_NEED_DYNAMIC_LIGHTMAP_UV
                
                #define HAVE_MESH_MODIFICATION
            
            
                #define SHADERPASS SHADERPASS_DECAL_GBUFFER_PROJECTOR
                #define _MATERIAL_AFFECTS_ALBEDO 1
                #define _MATERIAL_AFFECTS_NORMAL 1
                #define _MATERIAL_AFFECTS_NORMAL_BLEND 1
            
                // HybridV1InjectedBuiltinProperties: <None>
            
                // -- Properties used by ScenePickingPass
                #ifdef SCENEPICKINGPASS
                float4 _SelectionID;
                #endif
            
                // Includes
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/UnityGBuffer.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DecalInput.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderVariablesDecal.hlsl"
            
                // --------------------------------------------------
                // Structs and Packing
            
                struct Attributes
                {
                     float3 positionOS : POSITION;
                     float3 normalOS : NORMAL;
                     float4 uv0 : TEXCOORD0;
                    #if UNITY_ANY_INSTANCING_ENABLED
                     uint instanceID : INSTANCEID_SEMANTIC;
                    #endif
                };
                struct Varyings
                {
                     float4 positionCS : SV_POSITION;
                     float3 normalWS;
                     float4 texCoord0;
                     float3 viewDirectionWS;
                    #if defined(LIGHTMAP_ON)
                     float2 staticLightmapUV;
                    #endif
                    #if defined(DYNAMICLIGHTMAP_ON)
                     float2 dynamicLightmapUV;
                    #endif
                    #if !defined(LIGHTMAP_ON)
                     float3 sh;
                    #endif
                    #if UNITY_ANY_INSTANCING_ENABLED
                     uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };
                struct SurfaceDescriptionInputs
                {
                     float3 TangentSpaceNormal;
                     float4 uv0;
                };
                struct VertexDescriptionInputs
                {
                };
                struct PackedVaryings
                {
                     float4 positionCS : SV_POSITION;
                     float3 interp0 : INTERP0;
                     float4 interp1 : INTERP1;
                     float3 interp2 : INTERP2;
                     float2 interp3 : INTERP3;
                     float2 interp4 : INTERP4;
                     float3 interp5 : INTERP5;
                    #if UNITY_ANY_INSTANCING_ENABLED
                     uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };
            
                PackedVaryings PackVaryings (Varyings input)
                {
                    PackedVaryings output;
                    ZERO_INITIALIZE(PackedVaryings, output);
                    output.positionCS = input.positionCS;
                    output.interp0.xyz =  input.normalWS;
                    output.interp1.xyzw =  input.texCoord0;
                    output.interp2.xyz =  input.viewDirectionWS;
                    #if defined(LIGHTMAP_ON)
                    output.interp3.xy =  input.staticLightmapUV;
                    #endif
                    #if defined(DYNAMICLIGHTMAP_ON)
                    output.interp4.xy =  input.dynamicLightmapUV;
                    #endif
                    #if !defined(LIGHTMAP_ON)
                    output.interp5.xyz =  input.sh;
                    #endif
                    #if UNITY_ANY_INSTANCING_ENABLED
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }
                
                Varyings UnpackVaryings (PackedVaryings input)
                {
                    Varyings output;
                    output.positionCS = input.positionCS;
                    output.normalWS = input.interp0.xyz;
                    output.texCoord0 = input.interp1.xyzw;
                    output.viewDirectionWS = input.interp2.xyz;
                    #if defined(LIGHTMAP_ON)
                    output.staticLightmapUV = input.interp3.xy;
                    #endif
                    #if defined(DYNAMICLIGHTMAP_ON)
                    output.dynamicLightmapUV = input.interp4.xy;
                    #endif
                    #if !defined(LIGHTMAP_ON)
                    output.sh = input.interp5.xyz;
                    #endif
                    #if UNITY_ANY_INSTANCING_ENABLED
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }
                
            
                // --------------------------------------------------
                // Graph
            
                // Graph Properties
                CBUFFER_START(UnityPerMaterial)
                float4 Base_Map_TexelSize;
                float4 Normal_Map_TexelSize;
                float _DrawOrder;
                float _DecalMeshBiasType;
                float _DecalMeshDepthBias;
                float _DecalMeshViewBias;
                CBUFFER_END
                
                // Object and Global properties
                SAMPLER(SamplerState_Linear_Repeat);
                TEXTURE2D(Base_Map);
                SAMPLER(samplerBase_Map);
                TEXTURE2D(Normal_Map);
                SAMPLER(samplerNormal_Map);
            
                // Graph Functions
                // GraphFunctions: <None>
            
                // Graph Vertex
                struct VertexDescription
                {
                };
                
                VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                {
                    VertexDescription description = (VertexDescription)0;
                    return description;
                }
                
                // Graph Pixel
                struct SurfaceDescription
                {
                    float3 BaseColor;
                    float Alpha;
                    float3 NormalTS;
                    float NormalAlpha;
                };
                
                SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                {
                    SurfaceDescription surface = (SurfaceDescription)0;
                    UnityTexture2D _Property_9f1059a7a93a46ccab349515214f3ed2_Out_0 = UnityBuildTexture2DStructNoScale(Base_Map);
                    float4 _SampleTexture2D_7388a7ddbf6648ec92c3bb54ed055048_RGBA_0 = SAMPLE_TEXTURE2D(_Property_9f1059a7a93a46ccab349515214f3ed2_Out_0.tex, _Property_9f1059a7a93a46ccab349515214f3ed2_Out_0.samplerstate, _Property_9f1059a7a93a46ccab349515214f3ed2_Out_0.GetTransformedUV(IN.uv0.xy));
                    float _SampleTexture2D_7388a7ddbf6648ec92c3bb54ed055048_R_4 = _SampleTexture2D_7388a7ddbf6648ec92c3bb54ed055048_RGBA_0.r;
                    float _SampleTexture2D_7388a7ddbf6648ec92c3bb54ed055048_G_5 = _SampleTexture2D_7388a7ddbf6648ec92c3bb54ed055048_RGBA_0.g;
                    float _SampleTexture2D_7388a7ddbf6648ec92c3bb54ed055048_B_6 = _SampleTexture2D_7388a7ddbf6648ec92c3bb54ed055048_RGBA_0.b;
                    float _SampleTexture2D_7388a7ddbf6648ec92c3bb54ed055048_A_7 = _SampleTexture2D_7388a7ddbf6648ec92c3bb54ed055048_RGBA_0.a;
                    UnityTexture2D _Property_360e6833e8d64d75827ab98987b2b545_Out_0 = UnityBuildTexture2DStructNoScale(Normal_Map);
                    float4 _SampleTexture2D_1300b7cb738f4b18927411750039acd2_RGBA_0 = SAMPLE_TEXTURE2D(_Property_360e6833e8d64d75827ab98987b2b545_Out_0.tex, _Property_360e6833e8d64d75827ab98987b2b545_Out_0.samplerstate, _Property_360e6833e8d64d75827ab98987b2b545_Out_0.GetTransformedUV(IN.uv0.xy));
                    float _SampleTexture2D_1300b7cb738f4b18927411750039acd2_R_4 = _SampleTexture2D_1300b7cb738f4b18927411750039acd2_RGBA_0.r;
                    float _SampleTexture2D_1300b7cb738f4b18927411750039acd2_G_5 = _SampleTexture2D_1300b7cb738f4b18927411750039acd2_RGBA_0.g;
                    float _SampleTexture2D_1300b7cb738f4b18927411750039acd2_B_6 = _SampleTexture2D_1300b7cb738f4b18927411750039acd2_RGBA_0.b;
                    float _SampleTexture2D_1300b7cb738f4b18927411750039acd2_A_7 = _SampleTexture2D_1300b7cb738f4b18927411750039acd2_RGBA_0.a;
                    float _Float_8d7a8de17c23469e9a65a11b77cc9886_Out_0 = 0.63;
                    surface.BaseColor = (_SampleTexture2D_7388a7ddbf6648ec92c3bb54ed055048_RGBA_0.xyz);
                    surface.Alpha = _SampleTexture2D_7388a7ddbf6648ec92c3bb54ed055048_A_7;
                    surface.NormalTS = (_SampleTexture2D_1300b7cb738f4b18927411750039acd2_RGBA_0.xyz);
                    surface.NormalAlpha = _Float_8d7a8de17c23469e9a65a11b77cc9886_Out_0;
                    return surface;
                }
            
                // --------------------------------------------------
                // Build Graph Inputs
            
                
            //     $features.graphVertex:  $include("VertexAnimation.template.hlsl")
            //                                       ^ ERROR: $include cannot find file : VertexAnimation.template.hlsl. Looked into:
            // Packages/com.unity.shadergraph/Editor/Generation/Templates
            
                
            //     $features.graphPixel:   $include("SharedCode.template.hlsl")
            //                                       ^ ERROR: $include cannot find file : SharedCode.template.hlsl. Looked into:
            // Packages/com.unity.shadergraph/Editor/Generation/Templates
            
                SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                {
                    SurfaceDescriptionInputs output;
                    ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
                
                    /* WARNING: $splice Could not find named fragment 'CustomInterpolatorCopyToSDI' */
                
                
                
                    output.TangentSpaceNormal =                         float3(0.0f, 0.0f, 1.0f);
                
                
                    output.uv0 =                                        input.texCoord0;
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN                output.FaceSign =                                   IS_FRONT_VFACE(input.cullFace, true, false);
                #else
                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                #endif
                #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                
                    return output;
                }
                
            
                // --------------------------------------------------
                // Build Surface Data
            
                uint2 ComputeFadeMaskSeed(uint2 positionSS)
                {
                    uint2 fadeMaskSeed;
            
                    // Can't use the view direction, it is the same across the entire screen.
                    fadeMaskSeed = positionSS;
            
                    return fadeMaskSeed;
                }
            
                void GetSurfaceData(Varyings input, half3 viewDirectioWS, uint2 positionSS, float angleFadeFactor, out DecalSurfaceData surfaceData)
                {
                    #if (SHADERPASS == SHADERPASS_DBUFFER_PROJECTOR) || (SHADERPASS == SHADERPASS_FORWARD_EMISSIVE_PROJECTOR) || (SHADERPASS == SHADERPASS_DECAL_SCREEN_SPACE_PROJECTOR) || (SHADERPASS == SHADERPASS_DECAL_GBUFFER_PROJECTOR)
                        half4x4 normalToWorld = UNITY_ACCESS_INSTANCED_PROP(Decal, _NormalToWorld);
                        half fadeFactor = clamp(normalToWorld[0][3], 0.0f, 1.0f) * angleFadeFactor;
                        float2 scale = float2(normalToWorld[3][0], normalToWorld[3][1]);
                        float2 offset = float2(normalToWorld[3][2], normalToWorld[3][3]);
                        input.texCoord0.xy = input.texCoord0.xy * scale + offset;
                    #else
                        #ifdef LOD_FADE_CROSSFADE // enable dithering LOD transition if user select CrossFade transition in LOD group
                            LODDitheringTransition(ComputeFadeMaskSeed(positionSS), unity_LODFade.x);
                        #endif
            
                        half fadeFactor = half(1.0);
                    #endif
            
                    SurfaceDescriptionInputs surfaceDescriptionInputs = BuildSurfaceDescriptionInputs(input);
                    SurfaceDescription surfaceDescription = SurfaceDescriptionFunction(surfaceDescriptionInputs);
            
                    // setup defaults -- these are used if the graph doesn't output a value
                    ZERO_INITIALIZE(DecalSurfaceData, surfaceData);
                    surfaceData.occlusion = half(1.0);
                    surfaceData.smoothness = half(0);
            
                    #ifdef _MATERIAL_AFFECTS_NORMAL
                        surfaceData.normalWS.w = half(1.0);
                    #else
                        surfaceData.normalWS.w = half(0.0);
                    #endif
            
            
                    // copy across graph values, if defined
                    surfaceData.baseColor.xyz = half3(surfaceDescription.BaseColor);
                    surfaceData.baseColor.w = half(surfaceDescription.Alpha * fadeFactor);
            
                    #if (SHADERPASS == SHADERPASS_DBUFFER_PROJECTOR) || (SHADERPASS == SHADERPASS_DECAL_SCREEN_SPACE_PROJECTOR) || (SHADERPASS == SHADERPASS_DECAL_GBUFFER_PROJECTOR)
                        #if defined(_MATERIAL_AFFECTS_NORMAL)
                            surfaceData.normalWS.xyz = mul((half3x3)normalToWorld, surfaceDescription.NormalTS.xyz);
                        #else
                            surfaceData.normalWS.xyz = normalToWorld[2].xyz;
                        #endif
                    #elif (SHADERPASS == SHADERPASS_DBUFFER_MESH) || (SHADERPASS == SHADERPASS_DECAL_SCREEN_SPACE_MESH) || (SHADERPASS == SHADERPASS_DECAL_GBUFFER_MESH)
                        #if defined(_MATERIAL_AFFECTS_NORMAL)
                            float sgn = input.tangentWS.w;      // should be either +1 or -1
                            float3 bitangent = sgn * cross(input.normalWS.xyz, input.tangentWS.xyz);
                            half3x3 tangentToWorld = half3x3(input.tangentWS.xyz, bitangent.xyz, input.normalWS.xyz);
            
                            // We need to normalize as we use mikkt tangent space and this is expected (tangent space is not normalize)
                            surfaceData.normalWS.xyz = normalize(TransformTangentToWorld(surfaceDescription.NormalTS, tangentToWorld));
                        #else
                            surfaceData.normalWS.xyz = half3(input.normalWS); // Default to vertex normal
                        #endif
                    #endif
            
                    surfaceData.normalWS.w = surfaceDescription.NormalAlpha * fadeFactor;
            
                    // In case of Smoothness / AO / Metal, all the three are always computed but color mask can change
                }
            
                // --------------------------------------------------
                // Main
            
                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPassDecal.hlsl"
            
                ENDHLSL
            }
            Pass
            { 
                Name "DBufferMesh"
                Tags 
                { 
                    "LightMode" = "DBufferMesh"
                }
            
                // Render State
                Blend 0 SrcAlpha OneMinusSrcAlpha, Zero OneMinusSrcAlpha
                Blend 1 SrcAlpha OneMinusSrcAlpha, Zero OneMinusSrcAlpha
                Blend 2 SrcAlpha OneMinusSrcAlpha, Zero OneMinusSrcAlpha
                ZTest LEqual
                ZWrite Off
                ColorMask RGBA
                ColorMask RGBA 1
                ColorMask 0 2
            
                // Debug
                // <None>
            
                // --------------------------------------------------
                // Pass
            
                HLSLPROGRAM
            
                // Pragmas
                #pragma target 3.5
                #pragma vertex Vert
                #pragma fragment Frag
                #pragma multi_compile_instancing
            
                // Keywords
                #pragma multi_compile _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
                // GraphKeywords: <None>
            
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
            
                // Defines
                #define ATTRIBUTES_NEED_NORMAL
                #define ATTRIBUTES_NEED_TANGENT
                #define ATTRIBUTES_NEED_TEXCOORD0
                #define ATTRIBUTES_NEED_TEXCOORD1
                #define ATTRIBUTES_NEED_TEXCOORD2
                #define VARYINGS_NEED_POSITION_WS
                #define VARYINGS_NEED_NORMAL_WS
                #define VARYINGS_NEED_TANGENT_WS
                #define VARYINGS_NEED_TEXCOORD0
                
                #define HAVE_MESH_MODIFICATION
            
            
                #define SHADERPASS SHADERPASS_DBUFFER_MESH
                #define _MATERIAL_AFFECTS_ALBEDO 1
                #define _MATERIAL_AFFECTS_NORMAL 1
                #define _MATERIAL_AFFECTS_NORMAL_BLEND 1
            
                // HybridV1InjectedBuiltinProperties: <None>
            
                // -- Properties used by ScenePickingPass
                #ifdef SCENEPICKINGPASS
                float4 _SelectionID;
                #endif
            
                // Includes
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DecalInput.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderVariablesDecal.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
            
                // --------------------------------------------------
                // Structs and Packing
            
                struct Attributes
                {
                     float3 positionOS : POSITION;
                     float3 normalOS : NORMAL;
                     float4 tangentOS : TANGENT;
                     float4 uv0 : TEXCOORD0;
                     float4 uv1 : TEXCOORD1;
                     float4 uv2 : TEXCOORD2;
                    #if UNITY_ANY_INSTANCING_ENABLED
                     uint instanceID : INSTANCEID_SEMANTIC;
                    #endif
                };
                struct Varyings
                {
                     float4 positionCS : SV_POSITION;
                     float3 positionWS;
                     float3 normalWS;
                     float4 tangentWS;
                     float4 texCoord0;
                    #if UNITY_ANY_INSTANCING_ENABLED
                     uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };
                struct SurfaceDescriptionInputs
                {
                     float3 TangentSpaceNormal;
                     float4 uv0;
                };
                struct VertexDescriptionInputs
                {
                };
                struct PackedVaryings
                {
                     float4 positionCS : SV_POSITION;
                     float3 interp0 : INTERP0;
                     float3 interp1 : INTERP1;
                     float4 interp2 : INTERP2;
                     float4 interp3 : INTERP3;
                    #if UNITY_ANY_INSTANCING_ENABLED
                     uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };
            
                PackedVaryings PackVaryings (Varyings input)
                {
                    PackedVaryings output;
                    ZERO_INITIALIZE(PackedVaryings, output);
                    output.positionCS = input.positionCS;
                    output.interp0.xyz =  input.positionWS;
                    output.interp1.xyz =  input.normalWS;
                    output.interp2.xyzw =  input.tangentWS;
                    output.interp3.xyzw =  input.texCoord0;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }
                
                Varyings UnpackVaryings (PackedVaryings input)
                {
                    Varyings output;
                    output.positionCS = input.positionCS;
                    output.positionWS = input.interp0.xyz;
                    output.normalWS = input.interp1.xyz;
                    output.tangentWS = input.interp2.xyzw;
                    output.texCoord0 = input.interp3.xyzw;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }
                
            
                // --------------------------------------------------
                // Graph
            
                // Graph Properties
                CBUFFER_START(UnityPerMaterial)
                float4 Base_Map_TexelSize;
                float4 Normal_Map_TexelSize;
                float _DrawOrder;
                float _DecalMeshBiasType;
                float _DecalMeshDepthBias;
                float _DecalMeshViewBias;
                CBUFFER_END
                
                // Object and Global properties
                SAMPLER(SamplerState_Linear_Repeat);
                TEXTURE2D(Base_Map);
                SAMPLER(samplerBase_Map);
                TEXTURE2D(Normal_Map);
                SAMPLER(samplerNormal_Map);
            
                // Graph Functions
                // GraphFunctions: <None>
            
                // Graph Vertex
                struct VertexDescription
                {
                };
                
                VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                {
                    VertexDescription description = (VertexDescription)0;
                    return description;
                }
                
                // Graph Pixel
                struct SurfaceDescription
                {
                    float3 BaseColor;
                    float Alpha;
                    float3 NormalTS;
                    float NormalAlpha;
                };
                
                SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                {
                    SurfaceDescription surface = (SurfaceDescription)0;
                    UnityTexture2D _Property_9f1059a7a93a46ccab349515214f3ed2_Out_0 = UnityBuildTexture2DStructNoScale(Base_Map);
                    float4 _SampleTexture2D_7388a7ddbf6648ec92c3bb54ed055048_RGBA_0 = SAMPLE_TEXTURE2D(_Property_9f1059a7a93a46ccab349515214f3ed2_Out_0.tex, _Property_9f1059a7a93a46ccab349515214f3ed2_Out_0.samplerstate, _Property_9f1059a7a93a46ccab349515214f3ed2_Out_0.GetTransformedUV(IN.uv0.xy));
                    float _SampleTexture2D_7388a7ddbf6648ec92c3bb54ed055048_R_4 = _SampleTexture2D_7388a7ddbf6648ec92c3bb54ed055048_RGBA_0.r;
                    float _SampleTexture2D_7388a7ddbf6648ec92c3bb54ed055048_G_5 = _SampleTexture2D_7388a7ddbf6648ec92c3bb54ed055048_RGBA_0.g;
                    float _SampleTexture2D_7388a7ddbf6648ec92c3bb54ed055048_B_6 = _SampleTexture2D_7388a7ddbf6648ec92c3bb54ed055048_RGBA_0.b;
                    float _SampleTexture2D_7388a7ddbf6648ec92c3bb54ed055048_A_7 = _SampleTexture2D_7388a7ddbf6648ec92c3bb54ed055048_RGBA_0.a;
                    UnityTexture2D _Property_360e6833e8d64d75827ab98987b2b545_Out_0 = UnityBuildTexture2DStructNoScale(Normal_Map);
                    float4 _SampleTexture2D_1300b7cb738f4b18927411750039acd2_RGBA_0 = SAMPLE_TEXTURE2D(_Property_360e6833e8d64d75827ab98987b2b545_Out_0.tex, _Property_360e6833e8d64d75827ab98987b2b545_Out_0.samplerstate, _Property_360e6833e8d64d75827ab98987b2b545_Out_0.GetTransformedUV(IN.uv0.xy));
                    float _SampleTexture2D_1300b7cb738f4b18927411750039acd2_R_4 = _SampleTexture2D_1300b7cb738f4b18927411750039acd2_RGBA_0.r;
                    float _SampleTexture2D_1300b7cb738f4b18927411750039acd2_G_5 = _SampleTexture2D_1300b7cb738f4b18927411750039acd2_RGBA_0.g;
                    float _SampleTexture2D_1300b7cb738f4b18927411750039acd2_B_6 = _SampleTexture2D_1300b7cb738f4b18927411750039acd2_RGBA_0.b;
                    float _SampleTexture2D_1300b7cb738f4b18927411750039acd2_A_7 = _SampleTexture2D_1300b7cb738f4b18927411750039acd2_RGBA_0.a;
                    float _Float_8d7a8de17c23469e9a65a11b77cc9886_Out_0 = 0.63;
                    surface.BaseColor = (_SampleTexture2D_7388a7ddbf6648ec92c3bb54ed055048_RGBA_0.xyz);
                    surface.Alpha = _SampleTexture2D_7388a7ddbf6648ec92c3bb54ed055048_A_7;
                    surface.NormalTS = (_SampleTexture2D_1300b7cb738f4b18927411750039acd2_RGBA_0.xyz);
                    surface.NormalAlpha = _Float_8d7a8de17c23469e9a65a11b77cc9886_Out_0;
                    return surface;
                }
            
                // --------------------------------------------------
                // Build Graph Inputs
            
                
            //     $features.graphVertex:  $include("VertexAnimation.template.hlsl")
            //                                       ^ ERROR: $include cannot find file : VertexAnimation.template.hlsl. Looked into:
            // Packages/com.unity.shadergraph/Editor/Generation/Templates
            
                
            //     $features.graphPixel:   $include("SharedCode.template.hlsl")
            //                                       ^ ERROR: $include cannot find file : SharedCode.template.hlsl. Looked into:
            // Packages/com.unity.shadergraph/Editor/Generation/Templates
            
                SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                {
                    SurfaceDescriptionInputs output;
                    ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
                
                    /* WARNING: $splice Could not find named fragment 'CustomInterpolatorCopyToSDI' */
                
                
                
                    output.TangentSpaceNormal =                         float3(0.0f, 0.0f, 1.0f);
                
                
                    output.uv0 =                                        input.texCoord0;
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN                output.FaceSign =                                   IS_FRONT_VFACE(input.cullFace, true, false);
                #else
                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                #endif
                #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                
                    return output;
                }
                
            
                // --------------------------------------------------
                // Build Surface Data
            
                uint2 ComputeFadeMaskSeed(uint2 positionSS)
                {
                    uint2 fadeMaskSeed;
            
                    // Can't use the view direction, it is the same across the entire screen.
                    fadeMaskSeed = positionSS;
            
                    return fadeMaskSeed;
                }
            
                void GetSurfaceData(Varyings input, half3 viewDirectioWS, uint2 positionSS, float angleFadeFactor, out DecalSurfaceData surfaceData)
                {
                    #if (SHADERPASS == SHADERPASS_DBUFFER_PROJECTOR) || (SHADERPASS == SHADERPASS_FORWARD_EMISSIVE_PROJECTOR) || (SHADERPASS == SHADERPASS_DECAL_SCREEN_SPACE_PROJECTOR) || (SHADERPASS == SHADERPASS_DECAL_GBUFFER_PROJECTOR)
                        half4x4 normalToWorld = UNITY_ACCESS_INSTANCED_PROP(Decal, _NormalToWorld);
                        half fadeFactor = clamp(normalToWorld[0][3], 0.0f, 1.0f) * angleFadeFactor;
                        float2 scale = float2(normalToWorld[3][0], normalToWorld[3][1]);
                        float2 offset = float2(normalToWorld[3][2], normalToWorld[3][3]);
                        input.texCoord0.xy = input.texCoord0.xy * scale + offset;
                    #else
                        #ifdef LOD_FADE_CROSSFADE // enable dithering LOD transition if user select CrossFade transition in LOD group
                            LODDitheringTransition(ComputeFadeMaskSeed(positionSS), unity_LODFade.x);
                        #endif
            
                        half fadeFactor = half(1.0);
                    #endif
            
                    SurfaceDescriptionInputs surfaceDescriptionInputs = BuildSurfaceDescriptionInputs(input);
                    SurfaceDescription surfaceDescription = SurfaceDescriptionFunction(surfaceDescriptionInputs);
            
                    // setup defaults -- these are used if the graph doesn't output a value
                    ZERO_INITIALIZE(DecalSurfaceData, surfaceData);
                    surfaceData.occlusion = half(1.0);
                    surfaceData.smoothness = half(0);
            
                    #ifdef _MATERIAL_AFFECTS_NORMAL
                        surfaceData.normalWS.w = half(1.0);
                    #else
                        surfaceData.normalWS.w = half(0.0);
                    #endif
            
            
                    // copy across graph values, if defined
                    surfaceData.baseColor.xyz = half3(surfaceDescription.BaseColor);
                    surfaceData.baseColor.w = half(surfaceDescription.Alpha * fadeFactor);
            
                    #if (SHADERPASS == SHADERPASS_DBUFFER_PROJECTOR) || (SHADERPASS == SHADERPASS_DECAL_SCREEN_SPACE_PROJECTOR) || (SHADERPASS == SHADERPASS_DECAL_GBUFFER_PROJECTOR)
                        #if defined(_MATERIAL_AFFECTS_NORMAL)
                            surfaceData.normalWS.xyz = mul((half3x3)normalToWorld, surfaceDescription.NormalTS.xyz);
                        #else
                            surfaceData.normalWS.xyz = normalToWorld[2].xyz;
                        #endif
                    #elif (SHADERPASS == SHADERPASS_DBUFFER_MESH) || (SHADERPASS == SHADERPASS_DECAL_SCREEN_SPACE_MESH) || (SHADERPASS == SHADERPASS_DECAL_GBUFFER_MESH)
                        #if defined(_MATERIAL_AFFECTS_NORMAL)
                            float sgn = input.tangentWS.w;      // should be either +1 or -1
                            float3 bitangent = sgn * cross(input.normalWS.xyz, input.tangentWS.xyz);
                            half3x3 tangentToWorld = half3x3(input.tangentWS.xyz, bitangent.xyz, input.normalWS.xyz);
            
                            // We need to normalize as we use mikkt tangent space and this is expected (tangent space is not normalize)
                            surfaceData.normalWS.xyz = normalize(TransformTangentToWorld(surfaceDescription.NormalTS, tangentToWorld));
                        #else
                            surfaceData.normalWS.xyz = half3(input.normalWS); // Default to vertex normal
                        #endif
                    #endif
            
                    surfaceData.normalWS.w = surfaceDescription.NormalAlpha * fadeFactor;
            
                    // In case of Smoothness / AO / Metal, all the three are always computed but color mask can change
                }
            
                // --------------------------------------------------
                // Main
            
                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPassDecal.hlsl"
            
                ENDHLSL
            }
            Pass
            { 
                Name "DecalScreenSpaceMesh"
                Tags 
                { 
                    "LightMode" = "DecalScreenSpaceMesh"
                }
            
                // Render State
                Blend SrcAlpha OneMinusSrcAlpha
                ZTest LEqual
                ZWrite Off
            
                // Debug
                // <None>
            
                // --------------------------------------------------
                // Pass
            
                HLSLPROGRAM
            
                // Pragmas
                #pragma target 2.5
                #pragma vertex Vert
                #pragma fragment Frag
                #pragma multi_compile_instancing
                #pragma multi_compile_fog
            
                // Keywords
                #pragma multi_compile _ LIGHTMAP_ON
                #pragma multi_compile _ DYNAMICLIGHTMAP_ON
                #pragma multi_compile _ DIRLIGHTMAP_COMBINED
                #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
                #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
                #pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS
                #pragma multi_compile _ _SHADOWS_SOFT
                #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
                #pragma multi_compile _ SHADOWS_SHADOWMASK
                #pragma multi_compile _ _CLUSTERED_RENDERING
                #pragma multi_compile _DECAL_NORMAL_BLEND_LOW _DECAL_NORMAL_BLEND_MEDIUM _DECAL_NORMAL_BLEND_HIGH
                // GraphKeywords: <None>
            
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
            
                // Defines
                #define ATTRIBUTES_NEED_NORMAL
                #define ATTRIBUTES_NEED_TANGENT
                #define ATTRIBUTES_NEED_TEXCOORD0
                #define ATTRIBUTES_NEED_TEXCOORD1
                #define ATTRIBUTES_NEED_TEXCOORD2
                #define VARYINGS_NEED_POSITION_WS
                #define VARYINGS_NEED_NORMAL_WS
                #define VARYINGS_NEED_VIEWDIRECTION_WS
                #define VARYINGS_NEED_TANGENT_WS
                #define VARYINGS_NEED_TEXCOORD0
                #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                #define VARYINGS_NEED_SH
                #define VARYINGS_NEED_STATIC_LIGHTMAP_UV
                #define VARYINGS_NEED_DYNAMIC_LIGHTMAP_UV
                
                #define HAVE_MESH_MODIFICATION
            
            
                #define SHADERPASS SHADERPASS_DECAL_SCREEN_SPACE_MESH
                #define _MATERIAL_AFFECTS_ALBEDO 1
                #define _MATERIAL_AFFECTS_NORMAL 1
                #define _MATERIAL_AFFECTS_NORMAL_BLEND 1
            
                // HybridV1InjectedBuiltinProperties: <None>
            
                // -- Properties used by ScenePickingPass
                #ifdef SCENEPICKINGPASS
                float4 _SelectionID;
                #endif
            
                // Includes
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DecalInput.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderVariablesDecal.hlsl"
            
                // --------------------------------------------------
                // Structs and Packing
            
                struct Attributes
                {
                     float3 positionOS : POSITION;
                     float3 normalOS : NORMAL;
                     float4 tangentOS : TANGENT;
                     float4 uv0 : TEXCOORD0;
                     float4 uv1 : TEXCOORD1;
                     float4 uv2 : TEXCOORD2;
                    #if UNITY_ANY_INSTANCING_ENABLED
                     uint instanceID : INSTANCEID_SEMANTIC;
                    #endif
                };
                struct Varyings
                {
                     float4 positionCS : SV_POSITION;
                     float3 positionWS;
                     float3 normalWS;
                     float4 tangentWS;
                     float4 texCoord0;
                     float3 viewDirectionWS;
                    #if defined(LIGHTMAP_ON)
                     float2 staticLightmapUV;
                    #endif
                    #if defined(DYNAMICLIGHTMAP_ON)
                     float2 dynamicLightmapUV;
                    #endif
                    #if !defined(LIGHTMAP_ON)
                     float3 sh;
                    #endif
                     float4 fogFactorAndVertexLight;
                    #if UNITY_ANY_INSTANCING_ENABLED
                     uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };
                struct SurfaceDescriptionInputs
                {
                     float3 TangentSpaceNormal;
                     float4 uv0;
                };
                struct VertexDescriptionInputs
                {
                };
                struct PackedVaryings
                {
                     float4 positionCS : SV_POSITION;
                     float3 interp0 : INTERP0;
                     float3 interp1 : INTERP1;
                     float4 interp2 : INTERP2;
                     float4 interp3 : INTERP3;
                     float3 interp4 : INTERP4;
                     float2 interp5 : INTERP5;
                     float2 interp6 : INTERP6;
                     float3 interp7 : INTERP7;
                     float4 interp8 : INTERP8;
                    #if UNITY_ANY_INSTANCING_ENABLED
                     uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };
            
                PackedVaryings PackVaryings (Varyings input)
                {
                    PackedVaryings output;
                    ZERO_INITIALIZE(PackedVaryings, output);
                    output.positionCS = input.positionCS;
                    output.interp0.xyz =  input.positionWS;
                    output.interp1.xyz =  input.normalWS;
                    output.interp2.xyzw =  input.tangentWS;
                    output.interp3.xyzw =  input.texCoord0;
                    output.interp4.xyz =  input.viewDirectionWS;
                    #if defined(LIGHTMAP_ON)
                    output.interp5.xy =  input.staticLightmapUV;
                    #endif
                    #if defined(DYNAMICLIGHTMAP_ON)
                    output.interp6.xy =  input.dynamicLightmapUV;
                    #endif
                    #if !defined(LIGHTMAP_ON)
                    output.interp7.xyz =  input.sh;
                    #endif
                    output.interp8.xyzw =  input.fogFactorAndVertexLight;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }
                
                Varyings UnpackVaryings (PackedVaryings input)
                {
                    Varyings output;
                    output.positionCS = input.positionCS;
                    output.positionWS = input.interp0.xyz;
                    output.normalWS = input.interp1.xyz;
                    output.tangentWS = input.interp2.xyzw;
                    output.texCoord0 = input.interp3.xyzw;
                    output.viewDirectionWS = input.interp4.xyz;
                    #if defined(LIGHTMAP_ON)
                    output.staticLightmapUV = input.interp5.xy;
                    #endif
                    #if defined(DYNAMICLIGHTMAP_ON)
                    output.dynamicLightmapUV = input.interp6.xy;
                    #endif
                    #if !defined(LIGHTMAP_ON)
                    output.sh = input.interp7.xyz;
                    #endif
                    output.fogFactorAndVertexLight = input.interp8.xyzw;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }
                
            
                // --------------------------------------------------
                // Graph
            
                // Graph Properties
                CBUFFER_START(UnityPerMaterial)
                float4 Base_Map_TexelSize;
                float4 Normal_Map_TexelSize;
                float _DrawOrder;
                float _DecalMeshBiasType;
                float _DecalMeshDepthBias;
                float _DecalMeshViewBias;
                CBUFFER_END
                
                // Object and Global properties
                SAMPLER(SamplerState_Linear_Repeat);
                TEXTURE2D(Base_Map);
                SAMPLER(samplerBase_Map);
                TEXTURE2D(Normal_Map);
                SAMPLER(samplerNormal_Map);
            
                // Graph Functions
                // GraphFunctions: <None>
            
                // Graph Vertex
                struct VertexDescription
                {
                };
                
                VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                {
                    VertexDescription description = (VertexDescription)0;
                    return description;
                }
                
                // Graph Pixel
                struct SurfaceDescription
                {
                    float3 BaseColor;
                    float Alpha;
                    float3 NormalTS;
                    float NormalAlpha;
                };
                
                SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                {
                    SurfaceDescription surface = (SurfaceDescription)0;
                    UnityTexture2D _Property_9f1059a7a93a46ccab349515214f3ed2_Out_0 = UnityBuildTexture2DStructNoScale(Base_Map);
                    float4 _SampleTexture2D_7388a7ddbf6648ec92c3bb54ed055048_RGBA_0 = SAMPLE_TEXTURE2D(_Property_9f1059a7a93a46ccab349515214f3ed2_Out_0.tex, _Property_9f1059a7a93a46ccab349515214f3ed2_Out_0.samplerstate, _Property_9f1059a7a93a46ccab349515214f3ed2_Out_0.GetTransformedUV(IN.uv0.xy));
                    float _SampleTexture2D_7388a7ddbf6648ec92c3bb54ed055048_R_4 = _SampleTexture2D_7388a7ddbf6648ec92c3bb54ed055048_RGBA_0.r;
                    float _SampleTexture2D_7388a7ddbf6648ec92c3bb54ed055048_G_5 = _SampleTexture2D_7388a7ddbf6648ec92c3bb54ed055048_RGBA_0.g;
                    float _SampleTexture2D_7388a7ddbf6648ec92c3bb54ed055048_B_6 = _SampleTexture2D_7388a7ddbf6648ec92c3bb54ed055048_RGBA_0.b;
                    float _SampleTexture2D_7388a7ddbf6648ec92c3bb54ed055048_A_7 = _SampleTexture2D_7388a7ddbf6648ec92c3bb54ed055048_RGBA_0.a;
                    UnityTexture2D _Property_360e6833e8d64d75827ab98987b2b545_Out_0 = UnityBuildTexture2DStructNoScale(Normal_Map);
                    float4 _SampleTexture2D_1300b7cb738f4b18927411750039acd2_RGBA_0 = SAMPLE_TEXTURE2D(_Property_360e6833e8d64d75827ab98987b2b545_Out_0.tex, _Property_360e6833e8d64d75827ab98987b2b545_Out_0.samplerstate, _Property_360e6833e8d64d75827ab98987b2b545_Out_0.GetTransformedUV(IN.uv0.xy));
                    float _SampleTexture2D_1300b7cb738f4b18927411750039acd2_R_4 = _SampleTexture2D_1300b7cb738f4b18927411750039acd2_RGBA_0.r;
                    float _SampleTexture2D_1300b7cb738f4b18927411750039acd2_G_5 = _SampleTexture2D_1300b7cb738f4b18927411750039acd2_RGBA_0.g;
                    float _SampleTexture2D_1300b7cb738f4b18927411750039acd2_B_6 = _SampleTexture2D_1300b7cb738f4b18927411750039acd2_RGBA_0.b;
                    float _SampleTexture2D_1300b7cb738f4b18927411750039acd2_A_7 = _SampleTexture2D_1300b7cb738f4b18927411750039acd2_RGBA_0.a;
                    float _Float_8d7a8de17c23469e9a65a11b77cc9886_Out_0 = 0.63;
                    surface.BaseColor = (_SampleTexture2D_7388a7ddbf6648ec92c3bb54ed055048_RGBA_0.xyz);
                    surface.Alpha = _SampleTexture2D_7388a7ddbf6648ec92c3bb54ed055048_A_7;
                    surface.NormalTS = (_SampleTexture2D_1300b7cb738f4b18927411750039acd2_RGBA_0.xyz);
                    surface.NormalAlpha = _Float_8d7a8de17c23469e9a65a11b77cc9886_Out_0;
                    return surface;
                }
            
                // --------------------------------------------------
                // Build Graph Inputs
            
                
            //     $features.graphVertex:  $include("VertexAnimation.template.hlsl")
            //                                       ^ ERROR: $include cannot find file : VertexAnimation.template.hlsl. Looked into:
            // Packages/com.unity.shadergraph/Editor/Generation/Templates
            
                
            //     $features.graphPixel:   $include("SharedCode.template.hlsl")
            //                                       ^ ERROR: $include cannot find file : SharedCode.template.hlsl. Looked into:
            // Packages/com.unity.shadergraph/Editor/Generation/Templates
            
                SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                {
                    SurfaceDescriptionInputs output;
                    ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
                
                    /* WARNING: $splice Could not find named fragment 'CustomInterpolatorCopyToSDI' */
                
                
                
                    output.TangentSpaceNormal =                         float3(0.0f, 0.0f, 1.0f);
                
                
                    output.uv0 =                                        input.texCoord0;
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN                output.FaceSign =                                   IS_FRONT_VFACE(input.cullFace, true, false);
                #else
                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                #endif
                #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                
                    return output;
                }
                
            
                // --------------------------------------------------
                // Build Surface Data
            
                uint2 ComputeFadeMaskSeed(uint2 positionSS)
                {
                    uint2 fadeMaskSeed;
            
                    // Can't use the view direction, it is the same across the entire screen.
                    fadeMaskSeed = positionSS;
            
                    return fadeMaskSeed;
                }
            
                void GetSurfaceData(Varyings input, half3 viewDirectioWS, uint2 positionSS, float angleFadeFactor, out DecalSurfaceData surfaceData)
                {
                    #if (SHADERPASS == SHADERPASS_DBUFFER_PROJECTOR) || (SHADERPASS == SHADERPASS_FORWARD_EMISSIVE_PROJECTOR) || (SHADERPASS == SHADERPASS_DECAL_SCREEN_SPACE_PROJECTOR) || (SHADERPASS == SHADERPASS_DECAL_GBUFFER_PROJECTOR)
                        half4x4 normalToWorld = UNITY_ACCESS_INSTANCED_PROP(Decal, _NormalToWorld);
                        half fadeFactor = clamp(normalToWorld[0][3], 0.0f, 1.0f) * angleFadeFactor;
                        float2 scale = float2(normalToWorld[3][0], normalToWorld[3][1]);
                        float2 offset = float2(normalToWorld[3][2], normalToWorld[3][3]);
                        input.texCoord0.xy = input.texCoord0.xy * scale + offset;
                    #else
                        #ifdef LOD_FADE_CROSSFADE // enable dithering LOD transition if user select CrossFade transition in LOD group
                            LODDitheringTransition(ComputeFadeMaskSeed(positionSS), unity_LODFade.x);
                        #endif
            
                        half fadeFactor = half(1.0);
                    #endif
            
                    SurfaceDescriptionInputs surfaceDescriptionInputs = BuildSurfaceDescriptionInputs(input);
                    SurfaceDescription surfaceDescription = SurfaceDescriptionFunction(surfaceDescriptionInputs);
            
                    // setup defaults -- these are used if the graph doesn't output a value
                    ZERO_INITIALIZE(DecalSurfaceData, surfaceData);
                    surfaceData.occlusion = half(1.0);
                    surfaceData.smoothness = half(0);
            
                    #ifdef _MATERIAL_AFFECTS_NORMAL
                        surfaceData.normalWS.w = half(1.0);
                    #else
                        surfaceData.normalWS.w = half(0.0);
                    #endif
            
            
                    // copy across graph values, if defined
                    surfaceData.baseColor.xyz = half3(surfaceDescription.BaseColor);
                    surfaceData.baseColor.w = half(surfaceDescription.Alpha * fadeFactor);
            
                    #if (SHADERPASS == SHADERPASS_DBUFFER_PROJECTOR) || (SHADERPASS == SHADERPASS_DECAL_SCREEN_SPACE_PROJECTOR) || (SHADERPASS == SHADERPASS_DECAL_GBUFFER_PROJECTOR)
                        #if defined(_MATERIAL_AFFECTS_NORMAL)
                            surfaceData.normalWS.xyz = mul((half3x3)normalToWorld, surfaceDescription.NormalTS.xyz);
                        #else
                            surfaceData.normalWS.xyz = normalToWorld[2].xyz;
                        #endif
                    #elif (SHADERPASS == SHADERPASS_DBUFFER_MESH) || (SHADERPASS == SHADERPASS_DECAL_SCREEN_SPACE_MESH) || (SHADERPASS == SHADERPASS_DECAL_GBUFFER_MESH)
                        #if defined(_MATERIAL_AFFECTS_NORMAL)
                            float sgn = input.tangentWS.w;      // should be either +1 or -1
                            float3 bitangent = sgn * cross(input.normalWS.xyz, input.tangentWS.xyz);
                            half3x3 tangentToWorld = half3x3(input.tangentWS.xyz, bitangent.xyz, input.normalWS.xyz);
            
                            // We need to normalize as we use mikkt tangent space and this is expected (tangent space is not normalize)
                            surfaceData.normalWS.xyz = normalize(TransformTangentToWorld(surfaceDescription.NormalTS, tangentToWorld));
                        #else
                            surfaceData.normalWS.xyz = half3(input.normalWS); // Default to vertex normal
                        #endif
                    #endif
            
                    surfaceData.normalWS.w = surfaceDescription.NormalAlpha * fadeFactor;
            
                    // In case of Smoothness / AO / Metal, all the three are always computed but color mask can change
                }
            
                // --------------------------------------------------
                // Main
            
                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPassDecal.hlsl"
            
                ENDHLSL
            }
            Pass
            { 
                Name "DecalGBufferMesh"
                Tags 
                { 
                    "LightMode" = "DecalGBufferMesh"
                }
            
                // Render State
                Blend 0 SrcAlpha OneMinusSrcAlpha
                Blend 1 SrcAlpha OneMinusSrcAlpha
                Blend 2 SrcAlpha OneMinusSrcAlpha
                Blend 3 SrcAlpha OneMinusSrcAlpha
                ZWrite Off
                ColorMask RGB
                ColorMask 0 1
                ColorMask RGB 2
                ColorMask RGB 3
            
                // Debug
                // <None>
            
                // --------------------------------------------------
                // Pass
            
                HLSLPROGRAM
            
                // Pragmas
                #pragma target 3.5
                #pragma vertex Vert
                #pragma fragment Frag
                #pragma multi_compile_instancing
                #pragma multi_compile_fog
            
                // Keywords
                #pragma multi_compile _ LIGHTMAP_ON
                #pragma multi_compile _ DYNAMICLIGHTMAP_ON
                #pragma multi_compile _ DIRLIGHTMAP_COMBINED
                #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
                #pragma multi_compile _ _SHADOWS_SOFT
                #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
                #pragma multi_compile _ _MIXED_LIGHTING_SUBTRACTIVE
                #pragma multi_compile _DECAL_NORMAL_BLEND_LOW _DECAL_NORMAL_BLEND_MEDIUM _DECAL_NORMAL_BLEND_HIGH
                #pragma multi_compile _ _GBUFFER_NORMALS_OCT
                // GraphKeywords: <None>
            
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
            
                // Defines
                #define ATTRIBUTES_NEED_NORMAL
                #define ATTRIBUTES_NEED_TANGENT
                #define ATTRIBUTES_NEED_TEXCOORD0
                #define ATTRIBUTES_NEED_TEXCOORD1
                #define ATTRIBUTES_NEED_TEXCOORD2
                #define VARYINGS_NEED_POSITION_WS
                #define VARYINGS_NEED_NORMAL_WS
                #define VARYINGS_NEED_VIEWDIRECTION_WS
                #define VARYINGS_NEED_TANGENT_WS
                #define VARYINGS_NEED_TEXCOORD0
                #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                #define VARYINGS_NEED_SH
                #define VARYINGS_NEED_STATIC_LIGHTMAP_UV
                #define VARYINGS_NEED_DYNAMIC_LIGHTMAP_UV
                
                #define HAVE_MESH_MODIFICATION
            
            
                #define SHADERPASS SHADERPASS_DECAL_GBUFFER_MESH
                #define _MATERIAL_AFFECTS_ALBEDO 1
                #define _MATERIAL_AFFECTS_NORMAL 1
                #define _MATERIAL_AFFECTS_NORMAL_BLEND 1
            
                // HybridV1InjectedBuiltinProperties: <None>
            
                // -- Properties used by ScenePickingPass
                #ifdef SCENEPICKINGPASS
                float4 _SelectionID;
                #endif
            
                // Includes
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/UnityGBuffer.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DecalInput.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderVariablesDecal.hlsl"
            
                // --------------------------------------------------
                // Structs and Packing
            
                struct Attributes
                {
                     float3 positionOS : POSITION;
                     float3 normalOS : NORMAL;
                     float4 tangentOS : TANGENT;
                     float4 uv0 : TEXCOORD0;
                     float4 uv1 : TEXCOORD1;
                     float4 uv2 : TEXCOORD2;
                    #if UNITY_ANY_INSTANCING_ENABLED
                     uint instanceID : INSTANCEID_SEMANTIC;
                    #endif
                };
                struct Varyings
                {
                     float4 positionCS : SV_POSITION;
                     float3 positionWS;
                     float3 normalWS;
                     float4 tangentWS;
                     float4 texCoord0;
                     float3 viewDirectionWS;
                    #if defined(LIGHTMAP_ON)
                     float2 staticLightmapUV;
                    #endif
                    #if defined(DYNAMICLIGHTMAP_ON)
                     float2 dynamicLightmapUV;
                    #endif
                    #if !defined(LIGHTMAP_ON)
                     float3 sh;
                    #endif
                     float4 fogFactorAndVertexLight;
                    #if UNITY_ANY_INSTANCING_ENABLED
                     uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };
                struct SurfaceDescriptionInputs
                {
                     float3 TangentSpaceNormal;
                     float4 uv0;
                };
                struct VertexDescriptionInputs
                {
                };
                struct PackedVaryings
                {
                     float4 positionCS : SV_POSITION;
                     float3 interp0 : INTERP0;
                     float3 interp1 : INTERP1;
                     float4 interp2 : INTERP2;
                     float4 interp3 : INTERP3;
                     float3 interp4 : INTERP4;
                     float2 interp5 : INTERP5;
                     float2 interp6 : INTERP6;
                     float3 interp7 : INTERP7;
                     float4 interp8 : INTERP8;
                    #if UNITY_ANY_INSTANCING_ENABLED
                     uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };
            
                PackedVaryings PackVaryings (Varyings input)
                {
                    PackedVaryings output;
                    ZERO_INITIALIZE(PackedVaryings, output);
                    output.positionCS = input.positionCS;
                    output.interp0.xyz =  input.positionWS;
                    output.interp1.xyz =  input.normalWS;
                    output.interp2.xyzw =  input.tangentWS;
                    output.interp3.xyzw =  input.texCoord0;
                    output.interp4.xyz =  input.viewDirectionWS;
                    #if defined(LIGHTMAP_ON)
                    output.interp5.xy =  input.staticLightmapUV;
                    #endif
                    #if defined(DYNAMICLIGHTMAP_ON)
                    output.interp6.xy =  input.dynamicLightmapUV;
                    #endif
                    #if !defined(LIGHTMAP_ON)
                    output.interp7.xyz =  input.sh;
                    #endif
                    output.interp8.xyzw =  input.fogFactorAndVertexLight;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }
                
                Varyings UnpackVaryings (PackedVaryings input)
                {
                    Varyings output;
                    output.positionCS = input.positionCS;
                    output.positionWS = input.interp0.xyz;
                    output.normalWS = input.interp1.xyz;
                    output.tangentWS = input.interp2.xyzw;
                    output.texCoord0 = input.interp3.xyzw;
                    output.viewDirectionWS = input.interp4.xyz;
                    #if defined(LIGHTMAP_ON)
                    output.staticLightmapUV = input.interp5.xy;
                    #endif
                    #if defined(DYNAMICLIGHTMAP_ON)
                    output.dynamicLightmapUV = input.interp6.xy;
                    #endif
                    #if !defined(LIGHTMAP_ON)
                    output.sh = input.interp7.xyz;
                    #endif
                    output.fogFactorAndVertexLight = input.interp8.xyzw;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }
                
            
                // --------------------------------------------------
                // Graph
            
                // Graph Properties
                CBUFFER_START(UnityPerMaterial)
                float4 Base_Map_TexelSize;
                float4 Normal_Map_TexelSize;
                float _DrawOrder;
                float _DecalMeshBiasType;
                float _DecalMeshDepthBias;
                float _DecalMeshViewBias;
                CBUFFER_END
                
                // Object and Global properties
                SAMPLER(SamplerState_Linear_Repeat);
                TEXTURE2D(Base_Map);
                SAMPLER(samplerBase_Map);
                TEXTURE2D(Normal_Map);
                SAMPLER(samplerNormal_Map);
            
                // Graph Functions
                // GraphFunctions: <None>
            
                // Graph Vertex
                struct VertexDescription
                {
                };
                
                VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                {
                    VertexDescription description = (VertexDescription)0;
                    return description;
                }
                
                // Graph Pixel
                struct SurfaceDescription
                {
                    float3 BaseColor;
                    float Alpha;
                    float3 NormalTS;
                    float NormalAlpha;
                };
                
                SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                {
                    SurfaceDescription surface = (SurfaceDescription)0;
                    UnityTexture2D _Property_9f1059a7a93a46ccab349515214f3ed2_Out_0 = UnityBuildTexture2DStructNoScale(Base_Map);
                    float4 _SampleTexture2D_7388a7ddbf6648ec92c3bb54ed055048_RGBA_0 = SAMPLE_TEXTURE2D(_Property_9f1059a7a93a46ccab349515214f3ed2_Out_0.tex, _Property_9f1059a7a93a46ccab349515214f3ed2_Out_0.samplerstate, _Property_9f1059a7a93a46ccab349515214f3ed2_Out_0.GetTransformedUV(IN.uv0.xy));
                    float _SampleTexture2D_7388a7ddbf6648ec92c3bb54ed055048_R_4 = _SampleTexture2D_7388a7ddbf6648ec92c3bb54ed055048_RGBA_0.r;
                    float _SampleTexture2D_7388a7ddbf6648ec92c3bb54ed055048_G_5 = _SampleTexture2D_7388a7ddbf6648ec92c3bb54ed055048_RGBA_0.g;
                    float _SampleTexture2D_7388a7ddbf6648ec92c3bb54ed055048_B_6 = _SampleTexture2D_7388a7ddbf6648ec92c3bb54ed055048_RGBA_0.b;
                    float _SampleTexture2D_7388a7ddbf6648ec92c3bb54ed055048_A_7 = _SampleTexture2D_7388a7ddbf6648ec92c3bb54ed055048_RGBA_0.a;
                    UnityTexture2D _Property_360e6833e8d64d75827ab98987b2b545_Out_0 = UnityBuildTexture2DStructNoScale(Normal_Map);
                    float4 _SampleTexture2D_1300b7cb738f4b18927411750039acd2_RGBA_0 = SAMPLE_TEXTURE2D(_Property_360e6833e8d64d75827ab98987b2b545_Out_0.tex, _Property_360e6833e8d64d75827ab98987b2b545_Out_0.samplerstate, _Property_360e6833e8d64d75827ab98987b2b545_Out_0.GetTransformedUV(IN.uv0.xy));
                    float _SampleTexture2D_1300b7cb738f4b18927411750039acd2_R_4 = _SampleTexture2D_1300b7cb738f4b18927411750039acd2_RGBA_0.r;
                    float _SampleTexture2D_1300b7cb738f4b18927411750039acd2_G_5 = _SampleTexture2D_1300b7cb738f4b18927411750039acd2_RGBA_0.g;
                    float _SampleTexture2D_1300b7cb738f4b18927411750039acd2_B_6 = _SampleTexture2D_1300b7cb738f4b18927411750039acd2_RGBA_0.b;
                    float _SampleTexture2D_1300b7cb738f4b18927411750039acd2_A_7 = _SampleTexture2D_1300b7cb738f4b18927411750039acd2_RGBA_0.a;
                    float _Float_8d7a8de17c23469e9a65a11b77cc9886_Out_0 = 0.63;
                    surface.BaseColor = (_SampleTexture2D_7388a7ddbf6648ec92c3bb54ed055048_RGBA_0.xyz);
                    surface.Alpha = _SampleTexture2D_7388a7ddbf6648ec92c3bb54ed055048_A_7;
                    surface.NormalTS = (_SampleTexture2D_1300b7cb738f4b18927411750039acd2_RGBA_0.xyz);
                    surface.NormalAlpha = _Float_8d7a8de17c23469e9a65a11b77cc9886_Out_0;
                    return surface;
                }
            
                // --------------------------------------------------
                // Build Graph Inputs
            
                
            //     $features.graphVertex:  $include("VertexAnimation.template.hlsl")
            //                                       ^ ERROR: $include cannot find file : VertexAnimation.template.hlsl. Looked into:
            // Packages/com.unity.shadergraph/Editor/Generation/Templates
            
                
            //     $features.graphPixel:   $include("SharedCode.template.hlsl")
            //                                       ^ ERROR: $include cannot find file : SharedCode.template.hlsl. Looked into:
            // Packages/com.unity.shadergraph/Editor/Generation/Templates
            
                SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                {
                    SurfaceDescriptionInputs output;
                    ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
                
                    /* WARNING: $splice Could not find named fragment 'CustomInterpolatorCopyToSDI' */
                
                
                
                    output.TangentSpaceNormal =                         float3(0.0f, 0.0f, 1.0f);
                
                
                    output.uv0 =                                        input.texCoord0;
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN                output.FaceSign =                                   IS_FRONT_VFACE(input.cullFace, true, false);
                #else
                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                #endif
                #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                
                    return output;
                }
                
            
                // --------------------------------------------------
                // Build Surface Data
            
                uint2 ComputeFadeMaskSeed(uint2 positionSS)
                {
                    uint2 fadeMaskSeed;
            
                    // Can't use the view direction, it is the same across the entire screen.
                    fadeMaskSeed = positionSS;
            
                    return fadeMaskSeed;
                }
            
                void GetSurfaceData(Varyings input, half3 viewDirectioWS, uint2 positionSS, float angleFadeFactor, out DecalSurfaceData surfaceData)
                {
                    #if (SHADERPASS == SHADERPASS_DBUFFER_PROJECTOR) || (SHADERPASS == SHADERPASS_FORWARD_EMISSIVE_PROJECTOR) || (SHADERPASS == SHADERPASS_DECAL_SCREEN_SPACE_PROJECTOR) || (SHADERPASS == SHADERPASS_DECAL_GBUFFER_PROJECTOR)
                        half4x4 normalToWorld = UNITY_ACCESS_INSTANCED_PROP(Decal, _NormalToWorld);
                        half fadeFactor = clamp(normalToWorld[0][3], 0.0f, 1.0f) * angleFadeFactor;
                        float2 scale = float2(normalToWorld[3][0], normalToWorld[3][1]);
                        float2 offset = float2(normalToWorld[3][2], normalToWorld[3][3]);
                        input.texCoord0.xy = input.texCoord0.xy * scale + offset;
                    #else
                        #ifdef LOD_FADE_CROSSFADE // enable dithering LOD transition if user select CrossFade transition in LOD group
                            LODDitheringTransition(ComputeFadeMaskSeed(positionSS), unity_LODFade.x);
                        #endif
            
                        half fadeFactor = half(1.0);
                    #endif
            
                    SurfaceDescriptionInputs surfaceDescriptionInputs = BuildSurfaceDescriptionInputs(input);
                    SurfaceDescription surfaceDescription = SurfaceDescriptionFunction(surfaceDescriptionInputs);
            
                    // setup defaults -- these are used if the graph doesn't output a value
                    ZERO_INITIALIZE(DecalSurfaceData, surfaceData);
                    surfaceData.occlusion = half(1.0);
                    surfaceData.smoothness = half(0);
            
                    #ifdef _MATERIAL_AFFECTS_NORMAL
                        surfaceData.normalWS.w = half(1.0);
                    #else
                        surfaceData.normalWS.w = half(0.0);
                    #endif
            
            
                    // copy across graph values, if defined
                    surfaceData.baseColor.xyz = half3(surfaceDescription.BaseColor);
                    surfaceData.baseColor.w = half(surfaceDescription.Alpha * fadeFactor);
            
                    #if (SHADERPASS == SHADERPASS_DBUFFER_PROJECTOR) || (SHADERPASS == SHADERPASS_DECAL_SCREEN_SPACE_PROJECTOR) || (SHADERPASS == SHADERPASS_DECAL_GBUFFER_PROJECTOR)
                        #if defined(_MATERIAL_AFFECTS_NORMAL)
                            surfaceData.normalWS.xyz = mul((half3x3)normalToWorld, surfaceDescription.NormalTS.xyz);
                        #else
                            surfaceData.normalWS.xyz = normalToWorld[2].xyz;
                        #endif
                    #elif (SHADERPASS == SHADERPASS_DBUFFER_MESH) || (SHADERPASS == SHADERPASS_DECAL_SCREEN_SPACE_MESH) || (SHADERPASS == SHADERPASS_DECAL_GBUFFER_MESH)
                        #if defined(_MATERIAL_AFFECTS_NORMAL)
                            float sgn = input.tangentWS.w;      // should be either +1 or -1
                            float3 bitangent = sgn * cross(input.normalWS.xyz, input.tangentWS.xyz);
                            half3x3 tangentToWorld = half3x3(input.tangentWS.xyz, bitangent.xyz, input.normalWS.xyz);
            
                            // We need to normalize as we use mikkt tangent space and this is expected (tangent space is not normalize)
                            surfaceData.normalWS.xyz = normalize(TransformTangentToWorld(surfaceDescription.NormalTS, tangentToWorld));
                        #else
                            surfaceData.normalWS.xyz = half3(input.normalWS); // Default to vertex normal
                        #endif
                    #endif
            
                    surfaceData.normalWS.w = surfaceDescription.NormalAlpha * fadeFactor;
            
                    // In case of Smoothness / AO / Metal, all the three are always computed but color mask can change
                }
            
                // --------------------------------------------------
                // Main
            
                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPassDecal.hlsl"
            
                ENDHLSL
            }
            Pass
            { 
                Name "ScenePickingPass"
                Tags 
                { 
                    "LightMode" = "Picking"
                }
            
                // Render State
                Cull Back
            
                // Debug
                // <None>
            
                // --------------------------------------------------
                // Pass
            
                HLSLPROGRAM
            
                // Pragmas
                #pragma target 3.5
                #pragma vertex Vert
                #pragma fragment Frag
                #pragma multi_compile_instancing
            
                // Keywords
                // PassKeywords: <None>
                // GraphKeywords: <None>
            
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
            
                // Defines
                
                #define HAVE_MESH_MODIFICATION
            
            
                #define SHADERPASS SHADERPASS_DEPTHONLY
                #define SCENEPICKINGPASS 1
            
                // HybridV1InjectedBuiltinProperties: <None>
            
                // -- Properties used by ScenePickingPass
                #ifdef SCENEPICKINGPASS
                float4 _SelectionID;
                #endif
            
                // Includes
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DecalInput.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderVariablesDecal.hlsl"
            
                // --------------------------------------------------
                // Structs and Packing
            
                struct Attributes
                {
                     float3 positionOS : POSITION;
                    #if UNITY_ANY_INSTANCING_ENABLED
                     uint instanceID : INSTANCEID_SEMANTIC;
                    #endif
                };
                struct Varyings
                {
                     float4 positionCS : SV_POSITION;
                    #if UNITY_ANY_INSTANCING_ENABLED
                     uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };
                struct SurfaceDescriptionInputs
                {
                };
                struct VertexDescriptionInputs
                {
                };
                struct PackedVaryings
                {
                     float4 positionCS : SV_POSITION;
                    #if UNITY_ANY_INSTANCING_ENABLED
                     uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };
            
                PackedVaryings PackVaryings (Varyings input)
                {
                    PackedVaryings output;
                    ZERO_INITIALIZE(PackedVaryings, output);
                    output.positionCS = input.positionCS;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }
                
                Varyings UnpackVaryings (PackedVaryings input)
                {
                    Varyings output;
                    output.positionCS = input.positionCS;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }
                
            
                // --------------------------------------------------
                // Graph
            
                // Graph Properties
                CBUFFER_START(UnityPerMaterial)
                float4 Base_Map_TexelSize;
                float4 Normal_Map_TexelSize;
                float _DrawOrder;
                float _DecalMeshBiasType;
                float _DecalMeshDepthBias;
                float _DecalMeshViewBias;
                CBUFFER_END
                
                // Object and Global properties
                SAMPLER(SamplerState_Linear_Repeat);
                TEXTURE2D(Base_Map);
                SAMPLER(samplerBase_Map);
                TEXTURE2D(Normal_Map);
                SAMPLER(samplerNormal_Map);
            
                // Graph Functions
                // GraphFunctions: <None>
            
                // Graph Vertex
                struct VertexDescription
                {
                };
                
                VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                {
                    VertexDescription description = (VertexDescription)0;
                    return description;
                }
                
                // Graph Pixel
                struct SurfaceDescription
                {
                };
                
                SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                {
                    SurfaceDescription surface = (SurfaceDescription)0;
                    return surface;
                }
            
                // --------------------------------------------------
                // Build Graph Inputs
            
                
            //     $features.graphVertex:  $include("VertexAnimation.template.hlsl")
            //                                       ^ ERROR: $include cannot find file : VertexAnimation.template.hlsl. Looked into:
            // Packages/com.unity.shadergraph/Editor/Generation/Templates
            
                
            //     $features.graphPixel:   $include("SharedCode.template.hlsl")
            //                                       ^ ERROR: $include cannot find file : SharedCode.template.hlsl. Looked into:
            // Packages/com.unity.shadergraph/Editor/Generation/Templates
            
                SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                {
                    SurfaceDescriptionInputs output;
                    ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
                
                    /* WARNING: $splice Could not find named fragment 'CustomInterpolatorCopyToSDI' */
                
                
                
                
                
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN                output.FaceSign =                                   IS_FRONT_VFACE(input.cullFace, true, false);
                #else
                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                #endif
                #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                
                    return output;
                }
                
            
                // --------------------------------------------------
                // Build Surface Data
            
                uint2 ComputeFadeMaskSeed(uint2 positionSS)
                {
                    uint2 fadeMaskSeed;
            
                    // Can't use the view direction, it is the same across the entire screen.
                    fadeMaskSeed = positionSS;
            
                    return fadeMaskSeed;
                }
            
                void GetSurfaceData(Varyings input, half3 viewDirectioWS, uint2 positionSS, float angleFadeFactor, out DecalSurfaceData surfaceData)
                {
                    #if (SHADERPASS == SHADERPASS_DBUFFER_PROJECTOR) || (SHADERPASS == SHADERPASS_FORWARD_EMISSIVE_PROJECTOR) || (SHADERPASS == SHADERPASS_DECAL_SCREEN_SPACE_PROJECTOR) || (SHADERPASS == SHADERPASS_DECAL_GBUFFER_PROJECTOR)
                        half4x4 normalToWorld = UNITY_ACCESS_INSTANCED_PROP(Decal, _NormalToWorld);
                        half fadeFactor = clamp(normalToWorld[0][3], 0.0f, 1.0f) * angleFadeFactor;
                        float2 scale = float2(normalToWorld[3][0], normalToWorld[3][1]);
                        float2 offset = float2(normalToWorld[3][2], normalToWorld[3][3]);
                    #else
                        #ifdef LOD_FADE_CROSSFADE // enable dithering LOD transition if user select CrossFade transition in LOD group
                            LODDitheringTransition(ComputeFadeMaskSeed(positionSS), unity_LODFade.x);
                        #endif
            
                        half fadeFactor = half(1.0);
                    #endif
            
                    SurfaceDescriptionInputs surfaceDescriptionInputs = BuildSurfaceDescriptionInputs(input);
                    SurfaceDescription surfaceDescription = SurfaceDescriptionFunction(surfaceDescriptionInputs);
            
                    // setup defaults -- these are used if the graph doesn't output a value
                    ZERO_INITIALIZE(DecalSurfaceData, surfaceData);
                    surfaceData.occlusion = half(1.0);
                    surfaceData.smoothness = half(0);
            
                    #ifdef _MATERIAL_AFFECTS_NORMAL
                        surfaceData.normalWS.w = half(1.0);
                    #else
                        surfaceData.normalWS.w = half(0.0);
                    #endif
            
            
                    // copy across graph values, if defined
            
                    #if (SHADERPASS == SHADERPASS_DBUFFER_PROJECTOR) || (SHADERPASS == SHADERPASS_DECAL_SCREEN_SPACE_PROJECTOR) || (SHADERPASS == SHADERPASS_DECAL_GBUFFER_PROJECTOR)
                        #if defined(_MATERIAL_AFFECTS_NORMAL)
                        #else
                            surfaceData.normalWS.xyz = normalToWorld[2].xyz;
                        #endif
                    #elif (SHADERPASS == SHADERPASS_DBUFFER_MESH) || (SHADERPASS == SHADERPASS_DECAL_SCREEN_SPACE_MESH) || (SHADERPASS == SHADERPASS_DECAL_GBUFFER_MESH)
                        #if defined(_MATERIAL_AFFECTS_NORMAL)
                            float sgn = input.tangentWS.w;      // should be either +1 or -1
                            float3 bitangent = sgn * cross(input.normalWS.xyz, input.tangentWS.xyz);
                            half3x3 tangentToWorld = half3x3(input.tangentWS.xyz, bitangent.xyz, input.normalWS.xyz);
            
                            // We need to normalize as we use mikkt tangent space and this is expected (tangent space is not normalize)
                        #else
                            surfaceData.normalWS.xyz = half3(input.normalWS); // Default to vertex normal
                        #endif
                    #endif
            
            
                    // In case of Smoothness / AO / Metal, all the three are always computed but color mask can change
                }
            
                // --------------------------------------------------
                // Main
            
                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPassDecal.hlsl"
            
                ENDHLSL
            }
        }
        CustomEditorForRenderPipeline "UnityEditor.Rendering.Universal.DecalShaderGraphGUI" "UnityEngine.Rendering.Universal.UniversalRenderPipelineAsset"
        CustomEditor "UnityEditor.ShaderGraph.GenericShaderGraphMaterialGUI"
        FallBack "Hidden/Shader Graph/FallbackError"
    }