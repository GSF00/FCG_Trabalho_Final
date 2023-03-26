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
#define BUNNY  1
#define PLANE  2
#define AK     3
#define FACE   4
#define CUBE   5
#define SNIPER 6
#define SWORD  7
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
    vec4 l = normalize(vec4(1.0,1.0,0.5,0.0));

    // Vetor que define o sentido da câmera em relação ao ponto atual.
    vec4 v = normalize(camera_position - p);

    // Vetor que define o sentido da reflexão especular ideal.
    vec4 r = vec4(0.0,0.0,0.0,0.0); // o vetor de reflexão especular ideal

    r = -1*l + 2*dot(n, l)*n;

    float U = 0.0;
    float V = 0.0;

    // Parâmetros que definem as propriedades espectrais da superfície
    vec3 Kd; // Refletância difusa
    vec3 Ks; // Refletância especular
    vec3 Ka; // Refletância ambiente
    float q; // Expoente especular para o modelo de iluminação de Phong


    if(object_id == SPHERE || object_id == SKYBOX || object_id == SUN)
    {
        vec4 bbox_center = (bbox_min + bbox_max) / 2.0;

        vec4 p_prime = bbox_center + (position_model - bbox_center / length(position_model - bbox_center));

        U = (atan(-p_prime.z, p_prime.x) + M_PI) / (2*M_PI);
        V = (asin(p_prime.y) + M_PI_2) / M_PI;
    }

    else if (object_id == BUNNY)
    {
        // Propriedades espectrais do coelho
        Kd = vec3(0.08,0.8,0.4);
        Ks = vec3(0.8,0.8,0.8);
        Ka = vec3(0.04,0.2,0.4);
        q = 32.0;
    }
    else if ( object_id == PLANE )
    {
        /*
        Kd = vec3(0.2,0.6,0.2);
        Ks = vec3(0.3,0.3,0.3);
        Ka = vec3(0.0,0.0,0.0);
        q = 20.0;
*/

        // Coordenadas de textura do plano, obtidas do arquivo OBJ.
        U = texcoords.x;
        V = texcoords.y;

        //U = (position_model.x - bbox_min.x) / bbox_max.x - bbox_min.x;
        //V = (position_model.y - bbox_min.y) / bbox_max.y - bbox_min.y;

    }
    else if (object_id == AMONG || object_id == AMONG_BLUE || object_id == AMONG_GREEN || object_id == AMONG_ORANGE || object_id == AMONG_PINK || object_id == AMONG_WHITE || object_id == AMONG_YELLOW)
    {
        // Propriedades espectrais dos AmongUs
        U = texcoords.x;
        V = texcoords.y;
    }

    else if ( object_id == CUBE )
    {
        // Propriedades espectrais da espada
        Kd = vec3(0.1,0.1,0.1);
        Ks = vec3(0.0,0.0,0.0);
        Ka = vec3(0.1,0.1,0.1);
        q = 1.0;
    }
    else // Objeto desconhecido = preto
    {
        Kd = vec3(0.0,0.0,0.0);
        Ks = vec3(0.0,0.0,0.0);
        Ka = vec3(0.0,0.0,0.0);
        q = 1.0;
    }

    if(object_id == BUNNY || object_id == CUBE || object_id == FACE)
    {
        // Espectro da fonte de iluminação
        vec3 I = vec3(1.0,1.0,1.0); // o espectro da fonte de luz

        // Espectro da luz ambiente
        vec3 Ia = vec3(0.2,0.2,0.2); // o espectro da luz ambiente

        // Termo difuso utilizando a lei dos cossenos de Lambert
        vec3 lambert_diffuse_term = vec3(0.0,0.0,0.0); // o termo difuso de Lambert

        lambert_diffuse_term = max(0, dot(n, l))*Kd*I;

        // Termo ambiente
        vec3 ambient_term = vec3(0.0,0.0,0.0); // o termo ambiente

        ambient_term = Ka*Ia;

        // Termo especular utilizando o modelo de iluminação de Phong
        vec3 phong_specular_term  = vec3(0.0,0.0,0.0); // o termo especular de Phong

        phong_specular_term = Ks*I*pow(max(0, dot(r, v)),q);

        // Alpha default = 1 = 100% opaco = 0% transparente
        color.a = 1;

        // Cor final do fragmento calculada com uma combinação dos termos difuso,
        // especular, e ambiente. Veja slide 129 do documento Aula_17_e_18_Modelos_de_Iluminacao.pdf.
        color.rgb = lambert_diffuse_term + ambient_term + phong_specular_term;

        // Cor final com correção gamma, considerando monitor sRGB.
        color.rgb = pow(color.rgb, vec3(1.0,1.0,1.0)/2.2);
    }
    else if (object_id == SPHERE)
    {
        // Obtemos a refletância difusa a partir da leitura da imagem TextureImage0
        vec3 Kd0 = texture(TextureImage0, vec2(U,V)).rgb;

        // Equação de Iluminação
        float lambert = max(0,dot(n,l));

        color.rgb = Kd0 * (lambert + 0.03) + max(1 - 10*lambert, 0) * texture(TextureImage1, vec2(U,V)).rgb;

        // Alpha default = 1 = 100% opaco = 0% transparente
        color.a = 1;

        // Cor final com correção gamma, considerando monitor sRGB.
        color.rgb = pow(color.rgb, vec3(1.0,1.0,1.0)/2.2);
    }
    else if (object_id == PLANE)
    {
        U = texcoords.x;
        V = texcoords.y;

//        U = position_model.x;
//        V = position_model.y;

        // Obtemos a refletância difusa a partir da leitura da imagem TextureImage2
        vec3 Kd0 = texture(TextureImage2, vec2(U,V)).rgb;

        // Equação de Iluminação
        float lambert = max(0,dot(n,l));

        //color.rgb = Kd0;

        color.rgb = Kd0 * (1.0);

        // Alpha default = 1 = 100% opaco = 0% transparente
        color.a = 1;

        // Cor final com correção gamma, considerando monitor sRGB.
        color.rgb = pow(color.rgb, vec3(1.0,1.0,1.0)/2.2);
    }
    else if (object_id == GUN)
    {
        U = texcoords.x;
        V = texcoords.y;
        // Obtemos a refletância difusa a partir da leitura da imagem TextureImage3
        vec3 Kd0 = texture(TextureImage3, vec2(U,V)).rgb;

        // Equação de Iluminação
        float lambert = max(0,dot(n,l));

        color.rgb = Kd0;

        // Alpha default = 1 = 100% opaco = 0% transparente
        color.a = 1;

        // Cor final com correção gamma, considerando monitor sRGB.
        color.rgb = pow(color.rgb, vec3(1.0,1.0,1.0)/2.2);
    }
    else if (object_id == AMONG)
    {
        U = texcoords.x;
        V = texcoords.y;
        // Obtemos a refletância difusa a partir da leitura da imagem TextureImage4
        vec3 Kd0 = texture(TextureImage4, vec2(U,V)).rgb;

        // Equação de Iluminação
        float lambert = max(0,dot(n,l));

        color.rgb = Kd0;

        // Alpha default = 1 = 100% opaco = 0% transparente
        color.a = 1;

        // Cor final com correção gamma, considerando monitor sRGB.
        color.rgb = pow(color.rgb, vec3(1.0,1.0,1.0)/2.2);
    }
    else if (object_id == SKYBOX)
    {
        // Obtemos a refletância difusa a partir da leitura da imagem TextureImage5
        vec3 Kd0 = texture(TextureImage5, vec2(U,V)).rgb;

        // Equação de Iluminação
        float lambert = max(0,dot(n,l));

        color.rgb = Kd0 * (lambert + 0.03);

        // Alpha default = 1 = 100% opaco = 0% transparente
        color.a = 1;

        // Cor final com correção gamma, considerando monitor sRGB.
        color.rgb = pow(color.rgb, vec3(1.0,1.0,1.0)/2.2);
    }
    else if (object_id == SUN)
    {
        // Obtemos a refletância difusa a partir da leitura da imagem TextureImage6
        vec3 Kd0 = texture(TextureImage6, vec2(U,V)).rgb;

        // Equação de Iluminação
        float lambert = max(0,dot(n,l));

        color.rgb = Kd0;// * (lambert + 0.03);

        // Alpha default = 1 = 100% opaco = 0% transparente
        color.a = 1;

        // Cor final com correção gamma, considerando monitor sRGB.
        color.rgb = pow(color.rgb, vec3(1.0,1.0,1.0)/2.2);
    }
    else //if(object_id == AMONG_BLUE)
    {
//        U = texcoords.x;
//        V = texcoords.y;
////
        vec3 Kd0 = texture(TextureImage7, vec2(U,V)).rgb;
////
////        if(object_id == AMONG_GREEN)
////            vec3 Kd0 = texture(TextureImage8, vec2(U,V)).rgb;
////
////        if(object_id == AMONG_ORANGE)
////            vec3 Kd0 = texture(TextureImage9, vec2(U,V)).rgb;
////
////        if(object_id == AMONG_PINK)
////            vec3 Kd0 = texture(TextureImage10, vec2(U,V)).rgb;
////
////        if(object_id == AMONG_WHITE)
////            vec3 Kd0 = texture(TextureImage11, vec2(U,V)).rgb;
////
////        if(object_id == AMONG_YELLOW)
////            vec3 Kd0 = texture(TextureImage12, vec2(U,V)).rgb;
////
//        // Equação de Iluminação
//        float lambert = max(0,dot(n,l));

        color.rgb = Kd0;// * (lambert + 0.03);
//
//        // Alpha default = 1 = 100% opaco = 0% transparente
        color.a = 1;
//
//        // Cor final com correção gamma, considerando monitor sRGB.
        color.rgb = pow(color.rgb, vec3(1.0,1.0,1.0)/2.2);
    }
}

