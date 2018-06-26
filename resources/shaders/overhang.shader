[shaders]
vertex =
    uniform highp mat4 u_modelMatrix;
    uniform highp mat4 u_viewProjectionMatrix;
    uniform highp mat4 u_normalMatrix;

    attribute highp vec4 a_vertex;
    attribute highp vec4 a_normal;
    attribute highp vec2 a_uvs;

    varying highp vec3 f_vertex;
    varying highp vec3 f_normal;

    void main()
    {
        vec4 world_space_vert = u_modelMatrix * a_vertex;
        gl_Position = u_viewProjectionMatrix * world_space_vert;

        f_vertex = world_space_vert.xyz;
        f_normal = (u_normalMatrix * normalize(a_normal)).xyz;
    }

fragment =
    uniform mediump vec4 u_ambientColor;
    uniform mediump vec4 u_diffuseColor;
    uniform mediump vec4 u_specularColor;
    uniform highp vec3 u_lightPosition;
    uniform mediump float u_shininess;
    uniform highp vec3 u_viewPosition;

    uniform lowp float u_overhangAngle;
    uniform lowp vec4 u_overhangColor;
    uniform sampler2D u_extraOverhang; //Areas that should also be coloured as overhang.
    uniform highp vec2 u_windowSize;

    varying highp vec3 f_vertex;
    varying highp vec3 f_normal;

    void main()
    {

        mediump vec4 finalColor = vec4(0.0);

        // Ambient Component
        finalColor += u_ambientColor;

        highp vec3 normal = normalize(f_normal);
        highp vec3 lightDir = normalize(u_lightPosition - f_vertex);

        // Diffuse Component
        highp float NdotL = clamp(abs(dot(normal, lightDir)), 0.0, 1.0);
        finalColor += (NdotL * u_diffuseColor);

        // Specular Component
        // TODO: We should not do specularity for fragments facing away from the light.
        highp vec3 reflectedLight = reflect(-lightDir, normal);
        highp vec3 viewVector = normalize(u_viewPosition - f_vertex);
        highp float NdotR = clamp(dot(viewVector, reflectedLight), 0.0, 1.0);
        finalColor += pow(NdotR, u_shininess) * u_specularColor;

        finalColor = (-normal.y > u_overhangAngle) ? u_overhangColor : finalColor;
        highp vec2 extra_overhang_uv = vec2(gl_FragCoord.x / u_windowSize.x, 1.0 - gl_FragCoord.y / u_windowSize.y);
        vec4 is_extra_overhang = texture2D(u_extraOverhang, extra_overhang_uv);
        finalColor = is_extra_overhang * u_overhangColor + (1 - is_extra_overhang) * finalColor;

        gl_FragColor = finalColor;
        gl_FragColor.a = 1.0;
    }

vertex41core =
    #version 410
    uniform highp mat4 u_modelMatrix;
    uniform highp mat4 u_viewProjectionMatrix;
    uniform highp mat4 u_normalMatrix;

    in highp vec4 a_vertex;
    in highp vec4 a_normal;
    in highp vec2 a_uvs;

    out highp vec3 f_vertex;
    out highp vec3 f_normal;

    void main()
    {
        vec4 world_space_vert = u_modelMatrix * a_vertex;
        gl_Position = u_viewProjectionMatrix * world_space_vert;

        f_vertex = world_space_vert.xyz;
        f_normal = (u_normalMatrix * normalize(a_normal)).xyz;
    }

fragment41core =
    #version 410
    uniform mediump vec4 u_ambientColor;
    uniform mediump vec4 u_diffuseColor;
    uniform mediump vec4 u_specularColor;
    uniform highp vec3 u_lightPosition;
    uniform mediump float u_shininess;
    uniform highp vec3 u_viewPosition;

    uniform lowp float u_overhangAngle;
    uniform lowp vec4 u_overhangColor;
    uniform sampler2D u_extraOverhang; //Areas that should also be coloured as overhang.
    uniform highp vec2 u_windowSize;

    in highp vec3 f_vertex;
    in highp vec3 f_normal;

    out vec4 frag_color;

    void main()
    {

        mediump vec4 finalColor = vec4(0.0);

        // Ambient Component
        finalColor += u_ambientColor;

        highp vec3 normal = normalize(f_normal);
        highp vec3 lightDir = normalize(u_lightPosition - f_vertex);

        // Diffuse Component
        highp float NdotL = clamp(abs(dot(normal, lightDir)), 0.0, 1.0);
        finalColor += (NdotL * u_diffuseColor);

        // Specular Component
        // TODO: We should not do specularity for fragments facing away from the light.
        highp vec3 reflectedLight = reflect(-lightDir, normal);
        highp vec3 viewVector = normalize(u_viewPosition - f_vertex);
        highp float NdotR = clamp(dot(viewVector, reflectedLight), 0.0, 1.0);
        finalColor += pow(NdotR, u_shininess) * u_specularColor;

        finalColor = (-normal.y > u_overhangAngle) ? u_overhangColor : finalColor;
        highp vec2 extra_overhang_uv = vec2(gl_FragCoord.x / u_windowSize.x, 1.0 - gl_FragCoord.y / u_windowSize.y);
        vec4 is_extra_overhang = texture2D(u_extraOverhang, extra_overhang_uv);
        finalColor = is_extra_overhang * u_overhangColor + (1 - is_extra_overhang) * finalColor;

        frag_color = finalColor;
        frag_color.a = 1.0;
    }

[defaults]
u_ambientColor = [0.3, 0.3, 0.3, 1.0]
u_diffuseColor = [1.0, 0.79, 0.14, 1.0]
u_specularColor = [0.4, 0.4, 0.4, 1.0]
u_overhangColor = [1.0, 0.0, 0.0, 1.0]
u_shininess = 20.0

[bindings]
u_modelMatrix = model_matrix
u_viewProjectionMatrix = view_projection_matrix
u_normalMatrix = normal_matrix
u_viewPosition = view_position
u_lightPosition = light_0_position
u_diffuseColor = diffuse_color

[attributes]
a_vertex = vertex
a_normal = normal
