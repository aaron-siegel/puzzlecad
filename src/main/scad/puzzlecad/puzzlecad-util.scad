/***** String manipulation *****/
    
// Splits a string into a vector of tokens.
function strtok(str, sep, i=0, token="", result=[]) =
    is_undef(str) ? undef
    : len(str) == 0 ? []
    : i == len(str) ? concat(result, token)
    : str[i] == sep ? strtok(str, sep, i+1, "", concat(result, token))
    : strtok(str, sep, i+1, str(token, str[i]), result);

// Returns a substring of a given string.
function substr(str, pos=0, len=-1, substr="") =
    is_undef(str) ? undef :
    pos >= len(str) ? substr :
	len == 0 ? substr :
	len == -1 ? substr(str, pos, len(str)-pos, substr) :
	substr(str, pos+1, len-1, str(substr, str[pos]));
    
// Returns the next occurrence of char in str, starting at position i.
function strfind(str, char, i=0) =
    str[i] == undef ? undef :
    str[i] == char ? i :
    strfind(str, char, i+1);

function substr_until(str, char, pos=0, substr="") =
    str[pos] == undef ? undef :
    str[pos] == char ? substr :
    substr_until(str, char, pos+1, str(substr, str[pos]));
    
function lookup_kv(kv, key, default=undef, i=0) =
    kv[i] == undef ? default :
    kv[i][0] == key ? (kv[i][1] != undef ? kv[i][1] : true) :
    lookup_kv(kv, key, default, i+1);

function put_kv(kv, entry, i=0) =
    is_undef(kv) ? [entry] :
    i >= len(kv) ? concat(kv, [entry]) :
    kv[i][0] == entry[0] ? replace_in_list(kv, i, entry) :
    put_kv(kv, entry, i + 1);

function lookup_kv_unordered(kv, key, default=undef, i=0) =
    kv[i] == undef ? default :
    kv[i][0] == key || kv[i][0] == [key[1],key[0]] ? kv[i][1] :
    lookup_kv_unordered(kv, key, default, i+1);
    
function is_substr(str, substr, i = 0) =
      i > len(str) - len(substr) ? false
    : is_substr_at(str, substr, i) ? true
    : is_substr(str, substr, i + 1);
    
function is_substr_at(str, substr, i, j = 0) =
      j >= len(substr) ? true
    : str[i + j] != substr[j] ? false
    : is_substr_at(str, substr, i, j + 1);
    
function str_interpolate(str, args, i = 0) =
    i >= len(str) ? "" :
    let (arg_index = str[i] == "$" ? digit(str[i + 1]) : undef)
    is_undef(arg_index)
        ? str(str[i], str_interpolate(str, args, i + 1))
        : str(args[arg_index], str_interpolate(str, args, i + 2));
        
function mkstring(list, sep = "", i = 0) =
      i >= len(list) ? ""
    : i == len(list) - 1 ? list[i]
    : str(list[i], sep, mkstring(list, sep, i + 1));
             
function atof(str) =
    !is_string(str) ? undef :
    str[0] == "-" ? -atof2(str, 0, 1) :
    str[0] == "+" ? atof2(str, 0, 1) :
    atof2(str, 0, 0);
    
function atof2(str, value, pos) =
    pos == len(str) ? value :
    str[pos] == "." ? value + atof3(str, pos + 1) :
    atof2(str, 10 * value + digit(str[pos]), pos + 1);
    
function atof3(str, pos) =
    pos == len(str) ? 0 :
    (digit(str[pos]) + atof3(str, pos + 1)) / 10;

function digit(char) =
    char == "0" ? 0 : char == "1" ? 1 : char == "2" ? 2 : char == "3" ? 3 : char == "4" ? 4 :
    char == "5" ? 5 : char == "6" ? 6 : char == "7" ? 7 : char == "8" ? 8 : char == "9" ? 9 :
    undef;

/***** Vector manipulation *****/

function zyx_to_xyz(burr) =
    burr == [] ? [] :
    [ for (x = [0:len(burr[0][0])-1])
        [ for (y = [0:len(burr[0])-1])
            [ for (z = [0:len(burr)-1])
                burr[z][y][x]
            ]
        ]
    ];
            
function to_2_vector(a) = is_num(a) ? [a, a] : a;
 
function vectorize(a) = is_num(a) ? [a, a, a] : a;

function is_3_vector(a) = len(a) == 3 && is_num(a[0]) && is_num(a[1]) && is_num(a[2]);
    
function lookup3(array, vector) = array[vector.x][vector.y][vector.z];

// The componentwise (Hadamard) product of a and b.
            
function cw(a, b) = 
    a[0] == undef || b[0] == undef ? a * b : [ for (i=[0:min(len(a), len(b))-1]) a[i]*b[i] ];
        
function cw_inverse(a) = [ 1 / a.x, 1 / a.y, 1 / a.z ];
        
function unit_vector(vector) = vector / norm(vector);

function angle(a, b) = assert(!is_undef(a) && !is_undef(b), [a, b]) atan2(norm(cross(a, b)), a*b);
    
function values_are_close(ref, a, b) = abs(ref - a) < $poly_err_tolerance && abs(ref - b) < $poly_err_tolerance;

function polygon_normal(poly) =
    sum([ for (n=[0:len(poly)-1]) cross(poly[n], poly[(n+1) % len(poly)]) ]);

function poly_x(poly) = [ for (p = poly) p.x ];

function poly_y(poly) = [ for (p = poly) p.y ];

function range(vec) = max(vec) - min(vec);

function apply_rot(rotation, vector) =
    let (
        applied_x = [
            vector.x,
            vector.y * cos(rotation.x) - vector.z * sin(rotation.x),
            vector.z * cos(rotation.x) + vector.y * sin(rotation.x)
        ],
        applied_y = [
            applied_x.x * cos(rotation.y) + applied_x.z * sin(rotation.y),
            applied_x.y,
            applied_x.z * cos(rotation.y) - applied_x.x * sin(rotation.y)
        ],
        applied_z = [
            applied_y.x * cos(rotation.z) - applied_y.y * sin(rotation.z),
            applied_y.y * cos(rotation.z) + applied_y.x * sin(rotation.z),
            applied_y.z
        ]
    )
    applied_z;

/***** List manipulation *****/
    
function indices(list) = [0:len(list)-1];

function list_contains(list, element, k = 0) =
    k >= len(list) ? false : list[k] == element ? true : list_contains(list, element, k+1);

function index_of(list, element, k = 0) =
    k >= len(list) ? -1 : list[k] == element ? k : index_of(list, element, k + 1);

function add_to_list(list, element) = concat(list, [element]);

function remove_from_list(list, index) = [ for (k=indices(list)) if (k != index) list[k] ];
           
function replace_in_list(list, index, replacement) = [ for (k=indices(list)) k == index ? replacement : list[k] ];

function sublist(list, i, j) = i >= j ? [] : [ for (k=[i:j-1]) list[k] ];

function flatten(list) = [ for (l=list, x=l) x ];
    
function distinct(list, result = [], k = 0) =
      k >= len(list) ? result
    : list_contains(result, list[k]) ? distinct(list, result, k + 1)
    : distinct(list, concat(result, [list[k]]), k + 1);
    
function sum(list, k = 0) = k >= len(list) ? undef : k + 1 == len(list) ? list[k] : list[k] + sum(list, k+1);

function reverse_list(list, reverse = true) =
    reverse ? [ for (i = [len(list)-1:-1:0]) list[i] ] : list;
        
function repeat(n, item) = [ for (i = [1:n]) item ];

/***** Misc *****/

function argmin(list, i = 0, cur_argmin = undef, cur_min = undef) =
      i >= len(list) ? cur_argmin
    : is_undef(cur_argmin) || list[i] < cur_min ? argmin(list, i + 1, i, list[i])
    : argmin(list, i + 1, cur_argmin, cur_min);

// Version check. This is a proper implementation of semantic versioning.

module require_puzzlecad_version(required_version) {
    
    if (vector_compare(to_version_spec(puzzlecad_version), to_version_spec(required_version)) < 0) {
        assert(false, str(
            "ERROR: This model requires puzzlecad version ",
            required_version,
            ", and you are using version ",
            puzzlecad_version,
            ". Please upgrade before rendering."
        ));
    }
    
}

function to_version_spec(str) = [ for (element = strtok(strip_beta(str), ".")) atof(element) ];

function strip_beta(str) = let (b = index_of(str, "b")) b == -1 ? str : substr(str, 0, b);

function vector_compare(v1, v2, pos = 0) =
    pos >= max(len(v1), len(v2)) ? 0 :
    pos >= len(v1) ? 0 - v2[pos] :
    pos >= len(v2) ? v1[pos] - 0:
    v1[pos] != v2[pos] ? v1[pos] - v2[pos] :
    vector_compare(v1, v2, pos + 1);
