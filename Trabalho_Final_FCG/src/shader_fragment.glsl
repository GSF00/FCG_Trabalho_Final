#version 330 core

// Atributos de fragmentos recebidos como entrada ("in") pelo Fragment Shader.
// Neste exemplo, este atributo foi gerado pelo rasterizador como a
// interpolação da posição global e a normal de cada vértice, definidas em
// "shader_vertex.glsl" e "main.cpp".
in vec4 position_world;
in vec4 normal;

// Posição do vértice atual no sistema de coordenadas local do modelo.
in vec4 position_model;

// Coordenadas de textura obtidas do arquivo OBJ (se existirem!)
in vec2 texcoords;

// Matrizes computadas no código C++ e enviadas para a GPU
uniform mat4 model;
uniform mat4 view;
uniform mat4 projection;

// Identificador que define qual objeto está sendo desenhado no momento
#define SPHERE 0
#define PLANE  2
#define GUN    8
#define AMONG  9
#define SKYBOX 10
#define SUN    11
#define AMONG_BLUE 12
#define AMONG_GREEN 13
#define AMONG_ORANGE 14
#define AMONG_PINK 15
#define AMONG_WHITE 16
#define AMONG_YELLOW 17
#define AXE     18
#define START   19
#define VICTORY 20

uniform int object_id;

// Parâmetros da axis-aligned bounding box (AABB) do modelo
uniform vec4 bbox_min;
uniform vec4 bbox_max;

// Variáveis para acesso das imagens de textura
uniform sampler2D TextureImage0;
uniform sampler2D TextureImage1;
uniform sampler2D TextureImage2;
uniform sampler2D TextureImage3;
uniform sampler2D TextureImage4;
uniform sampler2D TextureImage5;
uniform sampler2D TextureImage6;
uniform sampler2D TextureImage7;
uniform sampler2D TextureImage8;
uniform sampler2D TextureImage9;
uniform sampler2D TextureImage10;
uniform sampler2D TextureImage11;
uniform sampler2D TextureImage12;
uniform sampler2D TextureImage13;
uniform sampler2D TextureImage14;
uniform sampler2D TextureImage15;

// O valor de saída ("out") de um Fragment Shader é a cor final do fragmento.
out vec4 color;

// Constantes
#define M_PI   3.14159265358979323846
#define M_PI_2 1.57079632679489661923

void main()
{
    // Obtemos a posição da câmera utilizando a inversa da matriz que define o
    // sistema de coordenadas da câmera.
    vec4 origin = vec4(0.0, 0.0, 0.0, 1.0);
    vec4 camera_position = inverse(view) * origin;

    // O fragmento atual é coberto por um ponto que percente à superfície de um
    // dos objetos virtuais da cena. Este ponto, p, possui uma posição no
    // sistema de coordenadas global (World coordinates). Esta posição é obtida
    // através da interpolação, feita pelo rasterizador, da posição de cada
    // vértice.
    vec4 p = position_world;

    // Normal do fragmento atual, interpolada pelo rasterizador a partir das
    // normais de cada vértice.
    vec4 n = normalize(normal);

    // Vetor que define o sentido da fonte de luz em relação ao ponto atual.
    vec4 l = normalize(vec4(1.0,1.0,1.0,0.0));

    // Vetor que define o sentido da câmera em relação ao ponto atual.
    vec4 v = normalize(camera_position - p);

    // Vetor que define o sentido da reflexão especular ideal.
    vec4 r = vec4(0.0,0.0,0.0,0.0); // o vetor de reflexão especular ideal

    r = -1*l + 2*dot(n, l)*n;

    float U = 0.0;
    float V = 0.0;

    // Parâmetros que definem as propriedades espectrais da superfície
    vec3 Kd0; // Refletância difusa
    vec3 Ks; // Refletância especular
    float q; // Expoente especular para o modelo de iluminação de Phong

    // Espectro da fonte de iluminação
    vec3 I = vec3(1.0,1.0,1.0); // o espectro da fonte de luz

    // Termo especular utilizando o modelo de iluminação de Phong
    vec3 phong_specular_term  = vec3(0.0,0.0,0.0);

    //phong_specular_term = Ks*I*pow(max(0, dot(r, v)),q);

    // Mapeamento de Textura
    if(object_id == SPHERE || object_id == SKYBOX || object_id == SUN)
    {
        vec4 bbox_center = (bbox_min + bbox_max) / 2.0;

        vec4 p_prime = bbox_center + (position_model - bbox_center / length(position_model - bbox_center));

        U = (atan(-p_prime.z, p_prime.x) + M_PI) / (2*M_PI);
        V = (asin(p_prime.y) + M_PI_2) / M_PI;
    }
    else
    {
        U = texcoords.x;
        V = texcoords.y;
    }


    // Equação de Iluminação
    float lambert = max(0,dot(n,l));

    if (object_id == SPHERE)
    {
        // Obtemos a refletância difusa a partir da leitura da imagem de textura
        Kd0 = texture(TextureImage0, vec2(U,V)).rgb;

        color.rgb = Kd0 * (lambert + 0.03) + max(1 - 10*lambert, 0) * texture(TextureImage1, vec2(U,V)).rgb;
    }
    else if (object_id == PLANE)
    {
        // Obtemos a refletância difusa a partir da leitura da imagem TextureImage2
        Kd0 = texture(TextureImage2, vec2(U,V)).rgb;
        color.rgb = Kd0 * (lambert + 0.03);
    }
    else if (object_id == AMONG)
    {
        // Obtemos a refletância difusa a partir da leitura da imagem TextureImage4
        Kd0 = texture(TextureImage4, vec2(U,V)).rgb;
        q = 20.0f;
        Ks = vec3(0.3f, 0.3f, 0.3f);
        phong_specular_term = Ks*I*pow(max(0, dot(r, v)),q);
        color.rgb = Kd0 * (lambert + 0.03) + phong_specular_term;
    }
    else if (object_id == SKYBOX)
    {
        // Obtemos a refletância difusa a partir da leitura da imagem TextureImage5
        Kd0 = texture(TextureImage5, vec2(U,V)).rgb;
        color.rgb = Kd0 * (lambert + 0.03);
    }
    else if (object_id == SUN)
    {
        // Obtemos a refletância difusa a partir da leitura da imagem TextureImage6
        Kd0 = texture(TextureImage6, vec2(U,V)).rgb;
        color.rgb = Kd0;
    }
    else if(object_id == AMONG_BLUE)
    {
        // Obtemos a refletância difusa a partir da leitura da imagem TextureImage7
        Kd0 = texture(TextureImage7, vec2(U,V)).rgb;
        q = 20.0f;
        Ks = vec3(0.3f, 0.3f, 0.3f);
        phong_specular_term = Ks*I*pow(max(0, dot(r, v)),q);
        color.rgb = Kd0 * (lambert + 0.03) + phong_specular_term;
    }
    else if(object_id == AMONG_GREEN)
    {
        // Obtemos a refletância difusa a partir da leitura da imagem TextureImage8
        Kd0 = texture(TextureImage8, vec2(U,V)).rgb;
        q = 20.0f;
        Ks = vec3(0.3f, 0.3f, 0.3f);
        phong_specular_term = Ks*I*pow(max(0, dot(r, v)),q);
        color.rgb = Kd0 * (lambert + 0.03) + phong_specular_term;
    }
    else if(object_id == AMONG_ORANGE)
    {
        // Obtemos a refletância difusa a partir da leitura da imagem TextureImage9
        Kd0 = texture(TextureImage9, vec2(U,V)).rgb;
        q = 20.0f;
        Ks = vec3(0.3f, 0.3f, 0.3f);
        phong_specular_term = Ks*I*pow(max(0, dot(r, v)),q);
        color.rgb = Kd0 * (lambert + 0.03) + phong_specular_term;
    }
    else if(object_id == AMONG_PINK)
    {
        // Obtemos a refletância difusa a partir da leitura da imagem TextureImage10
        Kd0 = texture(TextureImage10, vec2(U,V)).rgb;
        q = 20.0f;
        Ks = vec3(0.3f, 0.3f, 0.3f);
        phong_specular_term = Ks*I*pow(max(0, dot(r, v)),q);
        color.rgb = Kd0 * (lambert + 0.03) + phong_specular_term;
    }
    else if(object_id == AMONG_WHITE)
    {
        // Obtemos a refletância difusa a partir da leitura da imagem TextureImage11
        Kd0 = texture(TextureImage11, vec2(U,V)).rgb;
        q = 20.0f;
        Ks = vec3(0.3f, 0.3f, 0.3f);
        phong_specular_term = Ks*I*pow(max(0, dot(r, v)),q);
        color.rgb = Kd0 * (lambert + 0.03) + phong_specular_term;
    }
    else if(object_id == AMONG_YELLOW)
    {
        // Obtemos a refletância difusa a partir da leitura da imagem TextureImage12
        Kd0 = texture(TextureImage12, vec2(U,V)).rgb;
        q = 20.0f;
        Ks = vec3(0.3f, 0.3f, 0.3f);
        phong_specular_term = Ks*I*pow(max(0, dot(r, v)),q);
        color.rgb = Kd0 * (lambert + 0.03) + phong_specular_term;
    }
    else if(object_id == AXE)
    {
        // Obtemos a refletância difusa a partir da leitura da imagem TextureImage13
        Kd0 = texture(TextureImage13, vec2(U,V)).rgb;
        q = 20.0f;
        Ks = vec3(0.3f, 0.3f, 0.3f);
        phong_specular_term = Ks*I*pow(max(0, dot(r, v)),q);
        color.rgb = Kd0 * (lambert + 0.03) + phong_specular_term;
    }
    else if(object_id == START)
    {
        // Obtemos a refletância difusa a partir da leitura da imagem TextureImage14
        Kd0 = texture(TextureImage14, vec2(U,V)).rgb;
        color.rgb = Kd0;
    }
    else if(object_id == VICTORY)
    {
        // Obtemos a refletância difusa a partir da leitura da imagem TextureImage15
        Kd0 = texture(TextureImage15, vec2(U,V)).rgb;
        color.rgb = Kd0;
    }

    // Alpha default = 1 = 100% opaco = 0% transparente
    color.a = 1;

    // Cor final com correção gamma, considerando monitor sRGB.
    color.rgb = pow(color.rgb, vec3(1.0,1.0,1.0)/2.2);
}

