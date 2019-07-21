var documenterSearchIndex = {"docs": [

{
    "location": "bpp/#",
    "page": "The BPP formula for PI",
    "title": "The BPP formula for PI",
    "category": "page",
    "text": ""
},

{
    "location": "bpp/#Using-the-BBP-formula-1",
    "page": "The BPP formula for PI",
    "title": "Using the BBP formula",
    "category": "section",
    "text": "The Bailey–Borwein–Plouffe formula (BBP formula) is a formula for πusing FastRationals\n\nconst big1 = BigInt(1)\nconst big2 = BigInt(2)\nconst big4 = BigInt(4)\nconst big5 = BigInt(5)\nconst big6 = BigInt(6)\nconst big8 = BigInt(8)\nconst big16 = BigInt(16)\n\nfunction bpp(::Type{T}, n) where {T}\n    result = zero(T)\n    for k = 0:n\n       eightk = big8 * k\n       cur = T(big4,eightk+1) -\n             T(big2,eightk+4) -\n             T(big1,eightk+5) -\n             T(big1,eightk+6)\n       cur = T(big1, big16^k) * cur\n       result = result + cur\n    end\n    return result\nend\n\n# err ~1e-28, 403 digits in num, den\nsystemqtime = @belapsed bpp(Rational{BigInt},   20);\nfastqtime = @belapsed bpp(FastRational{BigInt}, 20);\nbpp20 = round(systemqtime/fastqtime, digits=1)\n\n# err ~1e-54, 1_328 digits in num, den\nsystemqtime = @belapsed bpp(Rational{BigInt},   40);\nfastqtime = @belapsed bpp(FastRational{BigInt}, 40);\nbpp40 = round(systemqtime/fastqtime, digits=1)\n\n# err ~1e-102, 4_671 digits in num, den\nsystemqtime = @belapsed bpp(Rational{BigInt},   80);\nfastqtime = @belapsed bpp(FastRational{BigInt}, 80);\nbpp80 = round(systemqtime/fastqtime, digits=1)\n\n# err ~1e247, 26_431 digits in num, den\nsystemqtime = @belapsed bpp(Rational{BigInt},   200);\nfastqtime = @belapsed bpp(FastRational{BigInt}, 200);\nbpp200 = round(systemqtime/fastqtime, digits=1)\n\n# err ~1e368, 57_914 digits in num, den\nsystemqtime = @belapsed bpp(Rational{BigInt},   300);\nfastqtime = @belapsed bpp(FastRational{BigInt}, 300);\nbpp300 = round(systemqtime/fastqtime, digits=1)\n\n# relspeeds meet at n=328\n\n# err ~1e368, 57_914 digits in num, den\nsystemqtime = @belapsed bpp(Rational{BigInt},   400);\nfastqtime = @belapsed bpp(FastRational{BigInt}, 400);\nbpp400 = round(systemqtime/fastqtime, digits=1)\n\n# err ~1e368, 57_914 digits in num, den\nsystemqtime = @belapsed bpp(Rational{BigInt},   500);\nfastqtime = @belapsed bpp(FastRational{BigInt}, 500);\nbpp500 = round(systemqtime/fastqtime, digits=1)\n"
},

{
    "location": "findingtherange/#",
    "page": "Finding the Range",
    "title": "Finding the Range",
    "category": "page",
    "text": ""
},

{
    "location": "findingtherange/#The-Rational-Range-1",
    "page": "Finding the Range",
    "title": "The Rational Range",
    "category": "section",
    "text": ""
},

{
    "location": "findingtherange/#the-rational-milieu-1",
    "page": "Finding the Range",
    "title": "the rational milieu",
    "category": "section",
    "text": "A rational value has two integer-valued components, the numerator and the denominator. Usually, rational arithmetic is applied to two values at a time.  muladd is applied to three rational values.  Here are *, + and muladd for rationals.(a/b * c/d) == (a * c) / (b * d)\n\n(a/b + c/d) == ((a * d) + (b * c)) / (b * d)\n\n(a/b * c/d) + s/t == ((a * c * t) + (b * d * s)) / (b * d * t)Without loss of generality, assume these are values of type Rational{Int32}.  We know each numerator and each denominator hold signed integer values stored in 32 bits.  One bit of an Int32 is used to keep the sign, so there are 31 bits available to hold a magnitude. <sup>𝓪</sup>   The maximum magnitude available is typemax(T), here typemax(Int32) == 2_147_483_647. This value becomes more meaningful when seen in hexadecimal (0x7fffffff), and to understand that, look at the first part in binary (0x7f == 0b0111_1111).  typemax(T) is an initial zero bit followed entirely by one bits, whenever T is built-in signed integer type.Why does it matter?  Multiplication of two of these component values will overflow unless there are enough leading zero bits available within those values.  The product of two B bit Signed system types cannot overflow when there are more than B+1 leading zero bits between the two values being multiplied. This is a sufficient characterization, and I prefer to work with a modicum of slack. The actual implementation uses B+2 to allow for results that obtain from adding two products, and keeping that slack. <sup>𝒃</sup><sup><a name=\"usefulfiction\">𝓪</a></sup> Actual Int32 quantities are kept as two\'s complement values, not sign+magnitude.<sup><a name=\"assumption1\">𝒃</a></sup> We have quietly assumed both are nonnegative values."
},

{
    "location": "thestatelessway/#",
    "page": "The Stateless Way",
    "title": "The Stateless Way",
    "category": "page",
    "text": ""
},

{
    "location": "thestatelessway/#Notes:-The-Stateless-Way-1",
    "page": "The Stateless Way",
    "title": "Notes:  The Stateless Way",
    "category": "section",
    "text": "The initial implementation of FastRationals for release uses one kind of type and makes this type available with two field sizes; they correspond to Julia\'s built-in Rational{Int32} and Rational{Int64} computational rational number types.struct FastRational{T} <: Real\n  num::T\n  den::T\nendT is either Int32 or it is Int64.Succesful use of ths type for FastRational requires finding some manner of effectiveness without the benefit of any reflective modality.  We have no state, flag, parameter or concommitant indication of whether or not the num and den as given have any common factors.  That is, there is no information about whether a given occurance of this type is already reduced, and so given in canonical form.  The other ways of realizing FastRationals each provides informed guidance as to the status, the reductive modality, of the value represented.      - insert page links to each of the other approaches <"
},

{
    "location": "thestatelessway/#making-something-of-use-1",
    "page": "The Stateless Way",
    "title": "making something of use",
    "category": "section",
    "text": "To allow computational advantage – to procure performance that is absent from the system rationals – we elevate a smaller range of magnitudes as preferred. With that, we presuppose and presume that this set of numerators aor denominators is that which pervades the rational values that are used within a computation.  This is not to require that all calculations resolve values that belong to this intially distinguished range.  This does strongly encourage most calculations to so resolve .. or not to stray too far away therefrom.  The entirety of this \"stateless way\" is given therewith. We may proceed with any calculation in this rational arithmetic by applying compensatory logic advantageously; we harvest the predeliction for, and liklihood of working with smaller rational values."
},

{
    "location": "thestatelessway/#when-overflow-is-less-likely-1",
    "page": "The Stateless Way",
    "title": "when overflow is less likely",
    "category": "section",
    "text": "Managing the resolution of overflow is an expensive incursion into the overall performance of the computational flow.  To the exent that we may proceed secure in the fact that our next calculation cannot overflow, we have at hand the opportunity to accelerate throughput.  By preferring a more coarse rational map, we lessen encounters with overflow and so augment performant paths.  In general terms, this is the technology that provides the greatly enhanced performance of this FastRational."
},

{
    "location": "thestatelessway/#quantifying-the-desireable-1",
    "page": "The Stateless Way",
    "title": "quantifying the desireable",
    "category": "section",
    "text": ""
},

{
    "location": "thestatelessway/#________-FastQ32-______________________________-FastQ64-__________-1",
    "page": "The Stateless Way",
    "title": "________  FastQ32  ______________________________  FastQ64  __________",
    "category": "section",
    "text": "|  range      | refinement  |                | range           | refinement     |   |:–––––-:|:–––––-:|:–––––––:|:–––––––-:|:–––––––:|   |             |             |                |                 |                |   |    ±215//1  |  ±1//215    |    sweet spot  |     ±55108//1  |  ±1//55108    |   |             |             |                |                 |                |   |    ±255//1  |  ±1//255    |    preferable  |     ±65535//1  |  ±1//65535    |   |             |             |                |                 |                |   |  ±1023//1  |  ±1//1023  |    workable    |   ±262143//1   |  ±1//262143   |   |             |             |                |                 |                |   | ±4095//1   |  ±1//4095  |    admissible  |  ±1048575//1  | ±1//1048575  |   |             |             |                |                 |                |The sweet_spot mag allows mag^4 + 5*mag without overflow.\nThe preferable mag is nextpow2(sweet_spot) - 1.\nThe workable mag is prevpow2(mag) - 1 where mag^3 + 4*mag, no overflow.\nThe admissible mag is 4*(workable+1) - 1"
},

{
    "location": "mayoverflow/#",
    "page": "What cannot overflow?",
    "title": "What cannot overflow?",
    "category": "page",
    "text": ""
},

{
    "location": "mayoverflow/#deriving-the-expresssion-for-mayoverflow:-1",
    "page": "What cannot overflow?",
    "title": "deriving the expresssion for mayoverflow:",
    "category": "section",
    "text": "bitsof(::Type{T}) where {T} = sizeof(T) * 8\nbitsof(x::T) where {T} = sizeof(T) * 8\n\n#=\n    maxmag(q) whichever is the larger, abs(numerator) or abs(denominator)\n    leading_zeros_maxmag(q) count of leading 0bits in maxmag(q)\n    msbitidx(q) 1-based bit index of the most significant bit in maxmag(q)\n                zero iff iszero(maxmag(q))\n=#\nmaxmag(q::Rational{T}) where {T<:Integer} = max(abs(q.num), abs(q.den))  \nleading_zeros_maxmag(q::Rational{T}) where {T<:Integer} = leading_zeros(maxmag(q))\n\nmsbitidx(q::Rational{T}) where {T<:Integer} = bitsof(T) - leading_zeros_maxmag(q)\nmsbitidx(q1::Rational{T}, q2::Rational{T}) where {T<:Integer} = msbitidx(q1) + msbitidx(q2)\n\nmaxmag(q::FastRational{T}) where {T<:FastInt} = max(abs(q.num), abs(q.den))  # q.den != typemin(T)\nleading_zeros_maxmag(q::FastRational{T}) where {T<:FastInt} = leading_zeros(maxmag(q))\n\nmsbitidx(q::FastRational{T}) where {T<:FastInt} = bitsof(T) - leading_zeros(maxmag(q))\nmsbitidx(q1::FastRational{T}, q2::FastRational{T}) where {T<:FastInt} = msbitidx(q1) + msbitidx(q2)\n\n#=\nmsbitidx(q1::T) + msbitidx(q2::T) \n    =  (bitsof(T) - leading_zeros(maxmag(q1))) + (bitsof(T) - leading_zeros(maxmag(q2)))\n    =  (bitsof(T) + bitsof(T)) - (leading_zeros(maxmag(q1)) + leading_zeros(maxmag(q2)))\n    =  2*bitsof(T) - (leading_zeros(maxmag(q1)) + leading_zeros(maxmag(q2)))\n=#\n\nmayoverflow(q1::T, q2::T) where {T} = bitsof(T) <= msbitidx(q1, q2)\n#=\n   = bitsof(T) <= 2*bitsof(T) - (leading_zeros(maxmag(q1)) + leading_zeros(maxmag(q2)))\n   = (leading_zeros(maxmag(q1)) + leading_zeros(maxmag(q2))) <= 2*bitsof(T) - bitsof(T)\n   = (leading_zeros(maxmag(q1)) + leading_zeros(maxmag(q2))) <= bitsof(T)\n=#\n\nmayoverflow(i1::T, i2::T) where {T<:Integer} =\n    (leading_zeros(i1) + leading_zeros(i2)) <= bitsof(T)\n\n#=\n   this was used in deriving the faster version immediately below\n   mayoverflow(q1::Rational{T}, q2::Rational{T}) where {T<:Integer} =\n        bitsof(T) >= leading_zeros_maxmag(q1) + leading_zeros_maxmag(q2)\n=#\n\nmayoverflow(q1::Rational{T}, q2::Rational{T}) where {T<:Integer} =\n    (bitsof(T)<<1) >= leading_zeros(q1.num) + leading_zeros(q1.den) +\n                      leading_zeros(q2.num) + leading_zeros(q2.den)\n\nmayoverflow(q1::FastRational{T}, q2::FastRational{T}) where {T<:FastInt} =\n    (bitsof(T)<<1) >= leading_zeros(q1.num) + leading_zeros(q1.den) +\n                      leading_zeros(q2.num) + leading_zeros(q2.den)"
},

{
    "location": "rationalmagnitude/#",
    "page": "Rational Magnitude In Action",
    "title": "Rational Magnitude In Action",
    "category": "page",
    "text": ""
},

{
    "location": "rationalmagnitude/#rational-magnitude-in-action-1",
    "page": "Rational Magnitude In Action",
    "title": "rational magnitude in action",
    "category": "section",
    "text": "This page delves deeper into the operational character of this current implementation for FastRationals.We use the leading terms of this series as an investigative tool, a metaphorical flashlight that works.the series formulation \n(Image: e_series) the source code here paints an informative picture."
},

{
    "location": "metaphoricalflashlight/#",
    "page": "A metaphor that illuminates",
    "title": "A metaphor that illuminates",
    "category": "page",
    "text": ""
},

{
    "location": "metaphoricalflashlight/#How-to-slow-FastRationals-1",
    "page": "A metaphor that illuminates",
    "title": "How to slow FastRationals",
    "category": "section",
    "text": "It is demonstrated that FastRationals are designed for use with rational values where both numerator and denominator are of relatively small magnitude.  We find that their performance strengthens with additional use and more terms .. right up to reaching the critical region of a swallow tail where the magnitudes engender unreduced overflow too often.Swallow Tail\n(Image: swallowtail)\nthis image appears courtesy of Goo Ishikawa"
},

{
    "location": "metaphoricalflashlight/#what-is-demonstrated-1",
    "page": "A metaphor that illuminates",
    "title": "what is demonstrated",
    "category": "section",
    "text": "The sequences and indicies appearing in this section were obtained by running the source text that follows.FastRational{Int32} most outperforms Rational{Int32} at index 6 (10x).\nthis is the largest index for which mayoverflow(_,_) == false.!mayoverflow(sum(fastq32_seqs[5]), fastq32_seqs[6][end]) &&\n mayoverflow(sum(fastq32_seqs[6]), fastq32_seqs[7][end])    === trueFastRational{Int64} most outperforms Rational{Int64} at index 8 (12x).\nthis is the largest index for which mayoverflow(_,_) == false.!mayoverflow(sum(fastq64_seqs[5]), fastq64_seqs[6][end]) &&\n mayoverflow(sum(fastq64_seqs[6]), fastq64_seqs[7][end])    === true"
},

{
    "location": "metaphoricalflashlight/#demonstration-1",
    "page": "A metaphor that illuminates",
    "title": "demonstration",
    "category": "section",
    "text": "using FastRationals, BenchmarkTools, MacroTools, Plots\n\n\nBenchmarkTools.DEFAULT_PARAMETERS.evals = 1;\nBenchmarkTools.DEFAULT_PARAMETERS.overhead = BenchmarkTools.estimate_overhead();\nBenchmarkTools.DEFAULT_PARAMETERS.time_tolerance = 2.0e-6;\nBenchmarkTools.DEFAULT_PARAMETERS.samples = 200;\nBenchmarkTools.DEFAULT_PARAMETERS.seconds = 3;\n\n\nwalk(x, inner, outer) = outer(x)\nwalk(x::Expr, inner, outer) = outer(Expr(x.head, map(inner, x.args)...))\npostwalk(f, x) = walk(x, x -> postwalk(f, x), f)\n\nfunction referred(expr::Expr)\n    if expr.head == :$\n        :($(Expr(:$, :(Ref($(expr.args...)))))[])\n    else\n        expr\n    end\nend\nreferred(x) = x\n\nmacro noelide(expr)\n    out = postwalk(referred, expr) |> esc\nend\n\n\n# using the Int64 Rational types\n\nnterms = 20;     # first 2 terms are (1//1), add one at the end \nrational_terms = [1//factorial(i) for i=1:nterms]; \nfastq64_terms  = FastRational{Int64}.(rational_terms);\n\n# we want successively longer sequences so we can chart computational behavior\nrational_seqs = [];\nfastq64_seqs  = [];\nfor i in 1:nterms\n     global rational_terms, fastq64terms, rational_seqs, fastq64_seqs\n     push!(rational_seqs, rational_terms[1:i])\n     push!(fastq64_seqs, fastq64_terms[1:i])\nend;\n\n# we time the summations so we can chart relative performance\nrational_times = [];\nfastq64_times  = [];\nfor i in 1:nterms\n     global rational_seqs, fastq64_seqs, rational_times, fastq64_times\n     rseq = rational_seqs[i]\n     fseq = fastq64_seqs[i]\n     rationaltime = @noelide @belapsed sum($rseq)\n     fastq64time  = @noelide @belapsed sum($fseq)\n     push!(rational_times, rationaltime)\n     push!(fastq64_times, fastq64time)\nend;\n\nrational_to_fast64 = Float32.(rational_times ./ fastq64_times);\n\n\n\n# using the Int32 Rational types\n\nnterms = 12;     # first 2 terms are (1//1), add one at the end \nrational_terms = Rational{Int32}.([1//factorial(i) for i=1:nterms]); \nfastq32_terms  = FastRational{Int32}.(rational_terms);\n\n# we want successively longer sequences so we can chart computational behavior\nrational_seqs = [];\nfastq32_seqs  = [];\nfor i in 1:nterms\n     global rational_terms, fastq32_terms, rational_seqs, fastq32_seqs\n     push!(rational_seqs, rational_terms[1:i])\n     push!(fastq32_seqs, fastq32_terms[1:i])\nend;\n\n# we time the summations so we can chart relative performance\nrational_times = [];\nfastq32_times  = [];\nfor i in 1:nterms\n     global rational_seqs, fastq32_seqs, rational_times, fastq32_times\n     rseq = rational_seqs[i]\n     fseq = fastq32_seqs[i]\n     rationaltime = @noelide @belapsed sum($rseq)\n     fastq32time  = @noelide @belapsed sum($fseq)\n     push!(rational_times, rationaltime)\n     push!(fastq32_times, fastq32time)\nend;\n\nrational_to_fast32 = Float32.(rational_times ./ fastq32_times);\n\n# isolate each maximum\n\nlen64 = length(rational_to_fast64);\nlen32 = length(rational_to_fast32);\nidxofmax_fastq64 = (1:len64)[maximum(rational_to_fast64) .== rational_to_fast64];\nidxofmax_fastq32 = (1:len32)[maximum(rational_to_fast32) .== rational_to_fast32];\n\n# plot\n\nplot(rational_to_fast64, size=(600,600))\nplot(rational_to_fast32, size=(600,600))\n\n# also use log plots\n\nlog_rational_to_fast64 = log.(rational_to_fast64);\nlog_rational_to_fast32 = [log.(rational_to_fast32)...,  log_rational_to_fast64[(end-(len64-len32)+1):end]...,];\n \nplot(log_rational_to_fast64, size=(600,600))\nplot!(log_rational_to_fast32)\n\n\nprintln(\"\\nThe maximum relative advantage of FastQ32 occured at index $idxofmax_fastq32\\n\")\nprintln(\"\\nThe maximum relative advantage of FastQ64 occured at index $idxofmax_fastq64\\n\")\n"
},

]}
