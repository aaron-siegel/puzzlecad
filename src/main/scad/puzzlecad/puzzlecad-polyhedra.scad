/* ====================================================================

  This is puzzlecad, an OpenSCAD library for modeling mechanical
  puzzles. It is provided as part of the Printable Puzzle Project:
  https://puzzlehub.org/ppp

  To obtain the latest version of puzzlecad:
  https://www.thingiverse.com/thing:3198014

  Puzzlecad code repository:
  https://github.com/aaron-siegel/puzzlecad

  puzzlecad is (c) 2019-2022 Aaron Siegel and is distributed under
  the MIT license. This means you may use or modify puzzlecad for any
  purposes, including commercial purposes, provided that you include
  the attribution "puzzlecad is (c) 2019-2022 Aaron Siegel" in any
  distributions or derivatives of puzzlecad, along with a copy of
  the MIT license.

  For details of this license, please refer to the LICENSE-MIT file
  distributed with puzzlecad, or visit:
  https://opensource.org/licenses/MIT

  NOTE THAT WHILE THE PUZZLECAD LIBRARY IS RELEASED UNDER THE MIT
  LICENSE, INDIVIDUAL PUZZLE DESIGNS (INCLUDING VARIOUS DESIGNS THAT
  ARE STORED IN THE PUZZLECAD GITHUB REPO) ARE SHARED UNDER A MORE
  RESTRICTIVE LICENSE. You may not use copyrighted puzzle designs for
  commercial purposes without explicit permission from the copyright
  holder(s).

==================================================================== */

/******* Modules for beveled shapes *******/

module beveled_cube(dim, center = false) {

    dim_vec = vectorize(dim);
    
    translate(center ? -dim_vec / 2 : [0, 0, 0])
    beveled_prism([[0, 0], [0, dim_vec.y], [dim_vec.x, dim_vec.y], [dim_vec.x, 0]], dim_vec.z);
    
}

module beveled_prism(polygon, height, center = false) {
    
    top = [ for (p = polygon) [ p.x, p.y, height ] ];
        
    assert(
        norm(unit_vector(polygon_normal(top)) - [0, 0, -1]) < $poly_err_tolerance,
        "beveled_prism: faces of the specified polygon must wind clockwise."
    );

    bottom = [ for (i = [len(polygon)-1:-1:0]) let (p = polygon[i]) [ p.x, p.y, 0] ];
        
    sides = [
        for (i = [0:len(polygon)-1])
        let (p = polygon[i], q = polygon[(i + len(polygon) - 1) % len(polygon)]) [
            [ p.x, p.y, 0 ], [ p.x, p.y, height ], [ q.x, q.y, height ], [q.x, q.y, 0 ]
    ] ];

    poly = make_beveled_poly(concat(sides, [top, bottom]));
        
    translate(center ? [0, 0, -height / 2] : [0, 0, 0])
    polyhedron(poly[0], poly[1]);
    
}

module beveled_polyhedron(points, faces) {
    
    literal_faces = [ for (f = faces) [ for (index = f) points[index] ] ];
    poly = make_beveled_poly(literal_faces);
    polyhedron(poly[0], poly[1]);
    
}

/***** Polyhedron Simplification *****/

function make_poly(faces) =
    let (foo = [ for (f = faces, p = f) assert(is_3_vector(p), str("Invalid polyhedron: ", f)) ])
    let (simplified_faces = remove_degeneracies(faces))
    let (merged_faces = merge_coplanar_faces(simplified_faces))
    make_poly_2(remove_degeneracies(merged_faces));
    
function make_poly_2(faces) =
    let (points = flatten(faces))
    let (point_index = make_point_index(quicksort_points(points)))
    let (mapped_faces = [ for (f=faces) [ for (p=f) index_of_point(point_index, p) ] ])
    let (reordered_faces = reorder_faces(mapped_faces))
    let (result = remove_unused_vertices(point_index, reordered_faces))
    let (dummy_var = validate_manifold(result[0], result[1]))
    result;
    
function remove_degeneracies(faces) =
    let (simplified_faces_1 = [ for (f = faces) remove_face_degeneracies(f) ])
    let (simplified_faces_2 = [ for (f = simplified_faces_1) remove_collinear_points(simplified_faces_1, f) ])
    let (simplified_faces_3 = [ for (f = simplified_faces_2) if (len(f) > 0) f ])
      faces == simplified_faces_3 ? faces               // No reductions happened
    : remove_degeneracies(simplified_faces_3);          // Something changed, so iterate
    
function remove_face_degeneracies(face) =
    let (reduced_face = remove_face_degeneracies_once(face))
      len(face) == len(reduced_face) ? reduced_face     // No reductions happened
    : remove_face_degeneracies(reduced_face);           // Something changed, so iterate

function remove_face_degeneracies_once(face) = len(face) == 0 ? [] : [
    for (k=[0:len(face)-1])
    let (foo = assert(is_3_vector(face[k]), face))
    if (norm(face[k] - face[(k+1) % len(face)]) >= $poly_err_tolerance &&
        norm(face[k] - face[(k+2) % len(face)]) >= $poly_err_tolerance &&
        norm(face[(k+len(face)-1) % len(face)] - face[(k+1) % len(face)]) >= $poly_err_tolerance)
    face[k]
];

// We can remove extraneous collinear points, mainly for reasons of efficiency. This has to
// be done carefully in order to preserve manifoldness: we can only shorten a collinear sequence of
// points [a, b, c] from one face *if* the edge pairings of [a, b] and [b, c] are also collinear,
// i.e., *if* the collinear sequence [c, b, a] appears on some other face.

function remove_collinear_points(faces, face) = len(face) == 0 ? [] : [
    for (k=[0:len(face)-1])
    let (a = face[(k-1+len(face)) % len(face)], b = face[k], c = face[(k+1) % len(face)])
    let (foo = assert(is_3_vector(a) && is_3_vector(b) && is_3_vector(c), face))
    if (norm(cross(b - a, c - b)) >= $poly_err_tolerance || !is_sequential_triplet(faces, [c, b, a]))
    face[k]
];

function is_sequential_triplet(faces, points, i = 0) =
      i >= len(faces) ? false
    : is_sequential_triplet_in_face(faces[i], points) ? true
    : is_sequential_triplet(faces, points, i + 1);

function is_sequential_triplet_in_face(face, points, j = 0) =
      j >= len(face) ? false
    : norm(face[j] - points[0]) < $poly_err_tolerance &&
      norm(face[(j+1) % len(face)] - points[1]) < $poly_err_tolerance &&
      norm(face[(j+2) % len(face)] - points[2]) < $poly_err_tolerance ? true
    : is_sequential_triplet_in_face(face, points, j + 1);

function num_faces_containing(faces, point) =
    sum([ for (face = faces) face_contains_point(face, point) ? 1 : 0 ]);
        
function face_contains_point(face, point, i = 0) =
      i >= len(face) ? false
    : norm(point - face[i]) < $poly_err_tolerance ? true
    : face_contains_point(face, point, i + 1);

// merge_coplanar_faces: find opportunities to merge adjacent coplanar faces, and iterate
// until reaching a state where no such opportunities exist.

function merge_coplanar_faces(faces) =
    let (merged_faces = remove_degeneracies(merge_coplanar_faces_once(faces)))
      len(faces) == len(merged_faces) ? merged_faces    // No mergers happened
    : merge_coplanar_faces(merged_faces);               // Something changed, so iterate

function merge_coplanar_faces_once(faces, i = 0) =
      i >= len(faces) ? faces
    : ( let (face_normal = polygon_normal(faces[i]))
        let (amalgamated_face_info = find_mergeable_face(faces, i, face_normal, i+1))
        is_undef(amalgamated_face_info) ? merge_coplanar_faces_once(faces, i+1)
          : // We found a way to merge another face with face i.
            let (coplanar_index = amalgamated_face_info[0])
            assert(coplanar_index > i)
            let(amalgamated_face = amalgamated_face_info[1])
            // Remove face coplanar_index from the list, and replace face i with the amalgamated face.
            merge_coplanar_faces_once(replace_in_list(remove_from_list(faces, coplanar_index), i, amalgamated_face), i)
       );

// find_merageable_face: find an adjacent coplanar face that can be merged with face face_index.
// If such a face is found, return [j, amalgam], where j is the index of the face to be merged
// and amalgam is the amalgamated face.

// To determine eligibility of the merge, a complex set of conditions must be evaluated. This is
// to ensure that the simplified polyhedron continues to meet OpenSCAD's fairly strict manifoldness
// requirements.

// First, we compute the surface normals and d-values of the two faces. (The d-value is equal to
// unit_vector(normal) * p, where p is any point on the polygon; two polygons lie on the same plane
// just if they have the same normal and d-value.)

// Then, two faces are mergeable provided that each of the following conditions holds:
// 1. *Either* they have the same normal and d-value, *or* one of the faces is degenerate (meaning
//    all its points are collinear).
// 2. The faces share at least one edge, but do not share multiple *nonconsecutive* edges. (If they
//    do, then merging them would yield a non-simply-connected face.)
// 3. Once the faces are merged, and after removing degeneracies from the amalgam, no vertex
//    appears in the amalgam more than once. (If a vertex does appear more than once, then the
//    amalgamated face has an interior cycle, which violates manifoldness.)

function find_mergeable_face(faces, face_index, face_normal, j) =

      j >= len(faces) ? undef

    : ( let (face1 = faces[face_index],
             face2 = faces[j],
             face2_normal = polygon_normal(faces[j]),
             face1_d = unit_vector(face_normal) * face1[0],
             face2_d = unit_vector(face2_normal) * face2[0])
             
        // Check condition 1. If either face is degenerate, or if they have the same normal and
        // d-value, then we can proceed.
        norm(face_normal) < $poly_err_tolerance || norm(face2_normal) < $poly_err_tolerance ||
        (norm(unit_vector(face_normal) - unit_vector(face2_normal)) < $poly_err_tolerance &&
         abs(face1_d - face2_d) < $poly_err_tolerance)
         
          ? let (indices = edge_pair_indices(face1, face2))
          
            // Check condition 2. If the faces share at least one edge, and all the shared edges
            // are consecutive along the face-cycle, then we can proceed.
            len(indices) > 0
                && are_indices_cyclically_consecutive(len(face1), [ for (epi = indices) epi[0] ])
                && are_indices_cyclically_consecutive(len(face2), [ for (epi = indices) epi[1] ])
                    
            ? let (amalgam = remove_face_degeneracies(amalgamate_faces(face1, face2, indices[0])))
              let (sorted_vertices = quicksort_points(amalgam))
              let (duplicate_vertex = find_duplicate_point(sorted_vertices))
                
                // Check condition 3. If there are no duplicate vertices in the amalgamated face,
                // then we've found a valid merge. Return the amalgam.
                is_undef(duplicate_vertex) ? [j, amalgam]
                
         // If any of the conditions failed, then try the next face.
                
                : find_mergeable_face(faces, face_index, face_normal, j + 1)
            : find_mergeable_face(faces, face_index, face_normal, j + 1)
          : find_mergeable_face(faces, face_index, face_normal, j + 1)

      );

function find_duplicate_point(sorted_list, i = 0) =
      i >= len(sorted_list) - 1 ? undef
    : norm(sorted_list[i] - sorted_list[i+1]) < $poly_err_tolerance ? i
    : find_duplicate_point(sorted_list, i + 1);

function amalgamate_faces(face1, face2, indices) =
    concat([ for (k=[1:len(face1)-1]) face1[(indices[0]+k) % len(face1)] ],
           [ for (k=[0:len(face2)-2]) face2[(indices[1]+k) % len(face2)] ]);

function edge_pair_indices(face1, face2) =
    [ for (i = [0:len(face1)-1])
        let (edge_pair = edge_pair_indices_2(face1, face2, i))
        if (!is_undef(edge_pair))
        edge_pair
    ];

function edge_pair_indices_2(face1, face2, i, j = 0) =
      j >= len(face2) ? undef
    : is_valid_edge_pair(face1, face2, i, j) ? [i, j]
    : edge_pair_indices_2(face1, face2, i, j+1);
           
function is_valid_edge_pair(face1, face2, i, j) =
    let(p = face1[i], q = face1[(i+1) % len(face1)])
    norm(p - face2[j]) < $poly_err_tolerance &&
    norm(q - face2[(j-1+len(face2)) % len(face2)]) < $poly_err_tolerance &&
    (norm(polygon_normal(face1)) >= $poly_err_tolerance || all_points_between(face1, p, q)) &&
    (norm(polygon_normal(face2)) >= $poly_err_tolerance || all_points_between(face2, p, q));

function all_points_between(points, p, q, i = 0) =
      i >= len(points) ? true
    : (points[i] - p) * (points[i] - q) >= $poly_err_tolerance ? false
    : all_points_between(points, p, q, i + 1);

function are_indices_cyclically_consecutive(length, indices) =
    let (transition_points = [
        for (i = [0:length-1])
        if (list_contains(indices, i) != list_contains(indices, (i + 1) % length))
        i ])
    len(transition_points) <= 2;
    
function make_point_index(points) = [
    for (n = [0:len(points)-1])
    if (n == 0 || abs(compare_points(points[n], points[n-1])) > $poly_err_tolerance)
    points[n]
];
    
function index_of_point(index, p) = index_of_point_rec(index, p, 0, len(index));

function index_of_point_rec(index, p, lower, upper) =
    assert(lower < upper + $poly_err_tolerance)
    let (mid = floor((upper + lower) / 2))
    let (cmp = compare_points(p, index[mid]))
      cmp < -$poly_err_tolerance ? index_of_point_rec(index, p, lower, mid)
    : cmp > $poly_err_tolerance ? index_of_point_rec(index, p, mid+1, upper)
    : mid;
    
function reorder_faces(faces) =
    quicksort_scalar_lists([ for (face = faces) reorder_face(face) ]);
        
function reorder_face(face) =
    let (first_index = minarg(face))
    [ for (i=[0:len(face)-1]) face[(first_index + i) % len(face)] ];

function remove_unused_vertices(vertices, faces) = let(
    used_vertices = [ for (v = [0:len(vertices)-1]) len(faces_containing_vertex(faces, v)) > 0 ],
    new_vertices = flatten([ for (v = [0:len(vertices)-1])
                len(faces_containing_vertex(faces, v)) > 0 ? [vertices[v]] : []
            ]),
    mapped_vertices = [ for (vertex = vertices) index_of(new_vertices, vertex) ],
    new_faces = [ for (face = faces) [ for (v = face) mapped_vertices[v] ] ]
    )
    [new_vertices, new_faces];
   
function minarg(list, i=0, current_min=undef, current_minarg=undef) =
      i >= len(list) ? current_minarg
    : is_undef(current_min) || list[i] < current_min ? minarg(list, i+1, list[i], i)
    : minarg(list, i+1, current_min, current_minarg);

function quicksort_integers(ints) = len(ints) == 0 ? [] : let(
    pivot   = ints[floor(len(ints)/2)],
    lesser  = [ for (y = ints) if (y < pivot) y ],
    equal   = [ for (y = ints) if (y == pivot) y ],
    greater = [ for (y = ints) if (y > pivot) y ]
) concat(
    quicksort_integers(lesser), equal, quicksort_integers(greater)
);

function quicksort_points(points) = len(points) == 0 ? [] : let(
    pivot   = points[floor(len(points)/2)],
    lesser  = [ for (y = points) if (compare_points(y, pivot) <= -$poly_err_tolerance) y ],
    equal   = [ for (y = points) if (abs(compare_points(y, pivot)) < $poly_err_tolerance) y ],
    greater = [ for (y = points) if (compare_points(y, pivot) >= $poly_err_tolerance) y ]
) concat(
    quicksort_points(lesser), equal, quicksort_points(greater)
);
    
function compare_points(a, b) =
    assert(is_list(a) && is_list(b))
    abs(a.x - b.x) < $poly_err_tolerance ? abs(a.y - b.y) < $poly_err_tolerance ? a.z - b.z : a.y - b.y : a.x - b.x;
    
function quicksort_scalar_lists(lists) = len(lists) == 0 ? [] : let(
    pivot   = lists[floor(len(lists)/2)],
    lesser  = [ for (y = lists) if (compare_scalar_lists(y, pivot) < 0) y ],
    equal   = [ for (y = lists) if (compare_scalar_lists(y, pivot) == 0) y ],
    greater = [ for (y = lists) if (compare_scalar_lists(y, pivot) > 0) y ]
) concat(
    quicksort_scalar_lists(lesser), equal, quicksort_scalar_lists(greater)
);
    
function compare_scalar_lists(a, b, i=0) =
      i >= len(a) && i >= len(b) ? 0
    : i >= len(b) ? 1
    : i >= len(a) ? -1
    : a[i] == b[i] ? compare_scalar_lists(a, b, i+1)
    : a[i] - b[i];

// TODO This checks for edge-validity, but not corner-validity
    
non_manifold_surface_err = "Non-manifold surface! This could be a bug in puzzlecad.";

function validate_manifold(points, faces) =
    let (
        all_edges = [ for (f = faces, i = [0:len(f)-1]) [ f[i], f[(i+1) % len(f)] ] ],
        sorted_edges = quicksort_scalar_lists(all_edges),
        reversed_edges = [ for (edge = all_edges) [ edge[1], edge[0] ] ],
        sorted_reversed_edges = quicksort_scalar_lists(reversed_edges)
    )
    let (duplicate_edge = find_duplicate(sorted_edges))
    assert(is_undef(duplicate_edge), str(non_manifold_surface_err, " Duplicate edge: ", sorted_edges[duplicate_edge]))
    assert(sorted_edges == sorted_reversed_edges, str(non_manifold_surface_err, " There are unpaired edge(s)."))
    let (degenerate_face = find_degenerate_face(points, faces))
    assert(is_undef(degenerate_face), str(non_manifold_surface_err, " Degenerate face: ", degenerate_face))
    //let (noncoplanar_face = find_noncoplanar_face(points, faces))
    //assert(is_undef(noncoplanar_face), str(non_manifold_surface_err, " Noncoplanar face: ", noncoplanar_face))
    let (cyclic_face = find_cyclic_face(faces))
    assert(is_undef(cyclic_face), str(non_manifold_surface_err, " Face has an internal cycle: ", cyclic_face));
 
function find_duplicate(sorted_list, i = 0) =
      i >= len(sorted_list) - 1 ? undef
    : sorted_list[i] == sorted_list[i+1] ? i
    : find_duplicate(sorted_list, i + 1);
        
function find_degenerate_face(points, faces, i = 0) =
      i >= len(faces) ? undef
    : let (face_normal = polygon_normal([ for (p = faces[i]) points[p] ]))
      !(norm(face_normal) >= $poly_err_tolerance) ? i
    : find_degenerate_face(points, faces, i + 1);
    
function find_cyclic_face(faces, i = 0) =
      i >= len(faces) ? undef
    : let (sorted_vertices = quicksort_integers(faces[i]))
      let (duplicate_vertex = find_duplicate(sorted_vertices))
      is_undef(duplicate_vertex) ? find_cyclic_face(faces, i + 1)
    : i;
    
function find_noncoplanar_face(points, faces, i = 0) =
      i >= len(faces) ? undef
    : !is_coplanar_polygon([ for (p = faces[i]) points[p] ]) ? i
    : find_noncoplanar_face(points, faces, i + 1);
    
function is_coplanar_polygon(poly) =
    let (polygon_normal = polygon_normal(poly),
         nonmatching_vertices = [ for (i = [0:len(poly)-1])
             let (a = poly[i], b = poly[(i+1) % len(poly)], c = poly[(i+2) % len(poly)])
             let (normal = cross(b - a, c - b))
             if (norm(normal) >= $poly_err_tolerance && norm(cross(normal, polygon_normal)) >= $poly_err_tolerance)
             i
         ])
    len(nonmatching_vertices) == 0;

/******* Polyhedron Beveling *******/

function make_beveled_poly(faces) =
      !has_beveling()
    ? make_poly(faces)
    : let (poly = make_poly(faces))
      let (beveled_poly = make_beveled_poly_normalized(poly[0], poly[1]))
      beveled_poly;
    
function has_beveling() =
    $burr_bevel >= 0.01 ||
    is_positive_bevel($burr_outer_x_bevel) ||
    is_positive_bevel($burr_outer_y_bevel) ||
    is_positive_bevel($burr_outer_z_bevel) ||
    !is_undef($burr_bevel_adjustments);
    
function is_positive_bevel(bevel) =
    is_undef(bevel) ? undef :
    let (bevel_or_pair = to_2_vector(bevel))
    bevel_or_pair[0] >= 0.01 || bevel_or_pair[1] >= 0.01;

function make_beveled_poly_normalized(vertices, faces) =

    assert((is_undef($burr_bevel_adjustments) ? 0 : 1) +
           (is_undef($burr_outer_x_bevel) ? 0 : 1) +
           (is_undef($burr_outer_y_bevel) ? 0 : 1) +
           (is_undef($burr_outer_z_bevel) ? 0 : 1)
           <= 1,
           "At most one can be specified: $burr_bevel_adjustments, $burr_outer_x_bevel, $burr_outer_y_bevel, $burr_outer_z_bevel")

    let(

    bevel_adjustments =
          !is_undef($burr_outer_x_bevel) ? outer_bevel_to_bevel_adj("x", to_2_vector($burr_outer_x_bevel))
        : !is_undef($burr_outer_y_bevel) ? outer_bevel_to_bevel_adj("y", to_2_vector($burr_outer_y_bevel))
        : !is_undef($burr_outer_z_bevel) ? outer_bevel_to_bevel_adj("z", to_2_vector($burr_outer_z_bevel))
        : !is_undef($burr_bevel_adjustments) ? parse_bevel_adjustments($burr_bevel_adjustments)
        : [],
    
    face_normals = [ for (face=faces) polygon_normal([ for (v=face) vertices[v] ]) ],
        
    // faces_containing[v] is a list of all the face ids containing vertex id v.
    faces_containing =
        [ for (v=[0:len(vertices)-1]) faces_containing_vertex(faces, v) ],

    // vf_connectors is a list of elements of the form [ [v, f], prev, next ]
    // where [v, f] is a vertex_id,face_id pair, and prev and next are vertices
    // preceding and succeeding v, in cyclic order on the oriented face f.
    vf_connectors =
        [ for (v=[0:len(vertices)-1], f=faces_containing[v])
          let (n = index_of(faces[f], v))
            [ [v, f], [faces[f][(n-1+len(faces[f])) % len(faces[f])],
                                 faces[f][(n+1) % len(faces[f])] ] ]
        ],
    
    // edge_face_pairings is a mapping from oriented edges to the face_id on
    // which those edges appear. Specifically, it's a list of elements of the
    // form [[v1, v2], f], where v1 and v2 are vertex ids specifying an
    // oriented edge, and f is the (unique) face on which that edge appears.      
    edge_face_pairings =
        [ for (f=[0:len(faces)-1], n=[0:len(faces[f])-1])
            [[faces[f][n], faces[f][(n+1) % len(faces[f])]], f]
        ],
        
    // edge_schemes is the "symmetrization" of edge_face_pairings: it's a list
    // of elements of the form [[v1, v2], f1, f2], where v1 and v2 are vertex
    // ids with v1 < v2, f1 is the "positively oriented" face touching that
    // edge (the face containing the oriented edge [v1, v2]), and f2 is the
    // "negatively oriented" face touching that edge (containing the oriented
    // edge [v2, v1]).
    edge_schemes =
        [ for (edge_face_pairing = edge_face_pairings)
            if (edge_face_pairing[0][0] < edge_face_pairing[0][1])
            let (other_face = lookup_kv(edge_face_pairings, [edge_face_pairing[0][1], edge_face_pairing[0][0]]))
            assert(!is_undef(other_face), str("Invalid polyhedron? Unpaired edge: ", edge_face_pairing))
            [ edge_face_pairing[0], edge_face_pairing[1], other_face ]
        ],
        
    // edge_convexities tells whether the faces joining each edge meet at a
    // convex or concave outer angle (values > 0 are convex).
    edge_convexities =
        [ for (edge_scheme = edge_schemes)
            let (edge_vector = vertices[edge_scheme[0][0]] - vertices[edge_scheme[0][1]],
                 edge_normal_1 = cross(edge_vector, face_normals[edge_scheme[1]]),
                 edge_normal_2 = cross(edge_vector, face_normals[edge_scheme[2]]))
            [edge_scheme[0], [cross(edge_normal_1, edge_normal_2) * edge_vector, 180 - angle(edge_normal_1, edge_normal_2)]]
        ],
        
    xmin = min([ for (v = vertices) v.x ]),
    xmax = max([ for (v = vertices) v.x ]),
    ymin = min([ for (v = vertices) v.y ]),
    ymax = max([ for (v = vertices) v.y ]),
    zmin = min([ for (v = vertices) v.z ]),
    zmax = max([ for (v = vertices) v.z ]),
        
    edge_bevelings =
        [ for (edge_scheme = edge_schemes)
            let (p = vertices[edge_scheme[0][0]], q = vertices[edge_scheme[0][1]])
            let (bevel = resolve_bevel_for_edge($burr_bevel, bevel_adjustments, xmin, xmax, ymin, ymax, zmin, zmax, p, q))
            [edge_scheme[0], bevel]
        ],

    convexity_signs =
        [ for (connector = vf_connectors)
          let (v = connector[0][0], f = connector[0][1], prev = connector[1][0], next = connector[1][1])
          let (vector1 = vertices[prev] - vertices[v], vector2 = vertices[next] - vertices[v])
          [ [v, f], cross(vector1, vector2) * face_normals[f] ]
        ],
        
    ordered_faces_containing =
        [ for (v=[0:len(vertices)-1]) ordered_faces_containing_vertex(faces, edge_face_pairings, v) ],

    // new_vertex_ids is a list of unique identifiers for vertices in the beveled polyhedron.
    // They take the form [v, f, loc], where f is a face id, v a vertex id appearing on that
    // face, and loc a sub-locator. The sub-locator will be 0 for convex [v, f]-pairs, and
    // -1 or 1 for concave.
    new_vertex_ids =
        [ for (v=[0:len(vertices)-1], f=faces_containing[v]) [v, f] ],
            
    new_vertex_id_lookup =
        [ for (id=[0:len(new_vertex_ids)-1]) [new_vertex_ids[id], id] ],
            
    new_vertex_locations = [
        
          for (c = vf_connectors)
          
          let (vertex = c[0][0], face = c[0][1], prev_vertex = c[1][0], next_vertex = c[1][1])
          
          let (inedge = vertices[vertex] - vertices[prev_vertex],
               outedge = vertices[next_vertex] - vertices[vertex],
               inedge_setback_dir = unit_vector(cross(-inedge, face_normals[face])),
               outedge_setback_dir = unit_vector(cross(-outedge, face_normals[face])),
               vertex_angle = angle(inedge, outedge),
               inedge_convexity = lookup_kv_unordered(edge_convexities, [prev_vertex, vertex]),
               outedge_convexity = lookup_kv_unordered(edge_convexities, [vertex, next_vertex]),
               inedge_bevel = lookup_kv_unordered(edge_bevelings, [prev_vertex, vertex])  /* * sqrt(1/2) / sin(inedge_convexity[1] / 2) */,
               outedge_bevel = lookup_kv_unordered(edge_bevelings, [vertex, next_vertex]) /* * sqrt(1/2) / sin(outedge_convexity[1] / 2) */
          )
          
          if (inedge_convexity[0] < 0.001 && outedge_convexity[0] < 0.001)
              // Two concave (and/or flat) edges: no beveling; vertex retains its original location.
              vertices[vertex]
          
          else if (inedge_convexity[0] < -0.001)
              // The inedge is concave, but the outedge is convex.
              vertices[vertex] - unit_vector(inedge) * outedge_bevel / sqrt(2) / sin(vertex_angle)
          
          else if (outedge_convexity[0] < -0.001)
              // The outedge is concave, but the inedge is convex.
              vertices[vertex] + unit_vector(outedge) * inedge_bevel / sqrt(2) / sin(vertex_angle)
          
          else
              // Two convex edges (one of which might be flat, but at least one of which is strictly convex).
              vertices[vertex] +
                  (inedge_setback_dir * inedge_bevel + outedge_setback_dir * outedge_bevel) / sqrt(2) /
                  (1 + inedge_setback_dir * outedge_setback_dir)

        ],
          
    new_ordinary_faces =
        [ for (f=[0:len(faces)-1]) [ for (v=faces[f]) [v, f] ] ],
        
    new_edge_bevel_faces =
        [ for (scheme=edge_schemes) let (
            v1 = scheme[0][0], v2 = scheme[0][1], f1 = scheme[1], f2 = scheme[2]
          ) ( [[v1, f1], [v1, f2], [v2, f2], [v2, f1]] ) ],
        
    start_indices_for_corner_bevel_faces =
        [ for (v=[0:len(vertices)-1])
            find_indices_for_corner_bevel_face(v, ordered_faces_containing[v], faces, edge_convexities)
        ],
        
    new_corner_bevel_faces =
        [ for (v=[0:len(vertices)-1])
          let (ofc = ordered_faces_containing[v])
          let (start_indices = start_indices_for_corner_bevel_faces[v])
          for (k = [0:len(start_indices)-1])
          let (start = start_indices[k])
          let (count = len(start_indices) == 1 ? len(ofc) : (start_indices[(k+1) % len(start_indices)] - start + len(ofc)) % len(ofc))
          if (count >= 3)
          for (w=[1:count-2])
          [ [v, ofc[start]], [v, ofc[(start + w) % len(ofc)]], [v, ofc[(start + w + 1) % len(ofc)]] ]
        ],
   
    new_faces = concat(new_ordinary_faces, new_edge_bevel_faces, new_corner_bevel_faces),
            
    literal_new_faces = [ for (f = new_faces) [ for (v = f) new_vertex_locations[lookup_kv(new_vertex_id_lookup, v)] ] ],
        
    linearized_new_faces =
        [ for (new_face = new_faces)
            [ for (v = new_face) lookup_kv(new_vertex_id_lookup, v) ],
        ]
            
    )
//    [new_vertex_locations, linearized_new_faces];
    make_poly(literal_new_faces);

function faces_containing_vertex(faces, vertex, k = 0) =
    k >= len(faces) ? []
    : list_contains(faces[k], vertex) ? concat([k], faces_containing_vertex(faces, vertex, k+1))
    : faces_containing_vertex(faces, vertex, k+1);

function ordered_faces_containing_vertex(faces, edge_face_pairings, vertex, k = 0) =
    k >= len(faces) ? []
    : list_contains(faces[k], vertex) ? ordered_faces_containing_vertex_2(faces, edge_face_pairings, vertex, [k])
    : ordered_faces_containing_vertex(faces, edge_face_pairings, vertex, k+1);

function ordered_faces_containing_vertex_2(faces, edge_face_pairings, vertex, list) =
    let(prev_face = list[len(list)-1])
    let(index_in_prev = index_of(faces[prev_face], vertex))
    let(prev_vertex_in_prev_face = faces[prev_face][(index_in_prev + len(faces[prev_face]) - 1) % len(faces[prev_face])])
    let(mirror_edge = [vertex, prev_vertex_in_prev_face])
    let(this_face = lookup_kv(edge_face_pairings, mirror_edge))
    this_face == list[0] ? list
        : ordered_faces_containing_vertex_2(faces, edge_face_pairings, vertex, concat(list, [this_face]));

function find_index_for_corner_bevel_face(v, ordered_faces_containing, faces, edge_convexities, k = 0) =
    k >= len(ordered_faces_containing) ? 0
    : let(f = ordered_faces_containing[k])
      let(index_in_face = index_of(faces[f], v))
      let(edge = [v, faces[f][(index_in_face + 1) % len(faces[f])]])
      let(convexity = lookup_kv_unordered(edge_convexities, edge))
      convexity[0] < 0 ? k
    : find_index_for_corner_bevel_face(v, ordered_faces_containing, faces, edge_convexities, k + 1);
        
function find_indices_for_corner_bevel_face(v, ordered_faces_containing, faces, edge_convexities, k = 0, result = []) =
    k >= len(ordered_faces_containing)
    ? (len(result) == 0 ? [find_index_for_corner_bevel_face(v, ordered_faces_containing, faces, edge_convexities)] : result)
    : let(f = ordered_faces_containing[k])
      let(index_in_face = index_of(faces[f], v))
      let(inedge = [faces[f][(index_in_face - 1 + len(faces[f])) % len(faces[f])], v])
      let(outedge = [v, faces[f][(index_in_face + 1) % len(faces[f])]])
      let(in_convexity = lookup_kv_unordered(edge_convexities, inedge))
      let(out_convexity = lookup_kv_unordered(edge_convexities, outedge))
      find_indices_for_corner_bevel_face(v, ordered_faces_containing, faces, edge_convexities, k + 1,
        in_convexity[0] < -0.001 && out_convexity[0] < -0.001 ? concat(result, [(k+1) % len(ordered_faces_containing)]) : result)
    ;

function outer_bevel_to_bevel_adj(dim, outer_bevel) =
    concat(
        is_undef(outer_bevel[0]) ? [] : [[str(dim, "-"), outer_bevel[0]]],
        is_undef(outer_bevel[1]) ? [] : [[str(dim, "+"), outer_bevel[1]]]
    );

function parse_bevel_adjustments(bevel_adj_string) =
    let (kv_map = parse_kv(bevel_adj_string))
    flatten([ for (entry = kv_map)
        assert(is_valid_bevel_adj(entry[0]), "Invalid $burr_bevel_adjustments.")
        let (value = atof(entry[1]))
        len(entry[0]) == 3     // Must be of the form z+o
            ? let (face_name = substr(entry[0], 0, 2),
                   face_id = index_of(cube_face_names, face_name))
              [ for (edge_name = cube_edge_names[face_id]) [ str(face_name, edge_name), value ] ]
            : [ [ entry[0], value ] ]
    ]);

function is_valid_bevel_adj(bevel_adj) =
    list_contains(cube_face_names, substr(bevel_adj, 0, 2)) &&
       len(bevel_adj) == 2
    || len(bevel_adj) == 3 && bevel_adj[2] == "o"
    || is_valid_orientation(bevel_adj);

function resolve_bevel_for_edge(default_bevel, bevel_adjustments, xmin, xmax, ymin, ymax, zmin, zmax, p, q, i = 0) =
      i >= len(bevel_adjustments) ? default_bevel
    : let (adj_type = bevel_adjustments[i][0], adj = bevel_adjustments[i][1])
      let (face_name = substr(adj_type, 0, 2))
      assert(list_contains(cube_face_names, face_name) || is_valid_orientation(adj_type))
      let (is_on_face = is_edge_on_outer_face(face_name, xmin, xmax, ymin, ymax, zmin, zmax, p, q))
      is_on_face && len(adj_type) == 2 ? adj
    : let (orth_face_name = substr(adj_type, 2, 2))
      is_on_face && is_edge_on_outer_face(orth_face_name, xmin, xmax, ymin, ymax, zmin, zmax, p, q) ? adj
    : resolve_bevel_for_edge(default_bevel, bevel_adjustments, xmin, xmax, ymin, ymax, zmin, zmax, p, q, i + 1);

function is_edge_on_outer_face(face_dir, xmin, xmax, ymin, ymax, zmin, zmax, p, q) =
       face_dir == "x-" && values_are_close(xmin, p.x, q.x)
    || face_dir == "x+" && values_are_close(xmax, p.x, q.x)
    || face_dir == "y-" && values_are_close(ymin, p.y, q.y)
    || face_dir == "y+" && values_are_close(ymax, p.y, q.y)
    || face_dir == "z-" && values_are_close(zmin, p.z, q.z)
    || face_dir == "z+" && values_are_close(zmax, p.z, q.z);
