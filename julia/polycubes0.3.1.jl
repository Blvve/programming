function polycube_counter24(n, placed, blocked, f)
	if length(placed) == n
		f(placed)
		return symmetries(placed)
	else
		available = get_available(placed, blocked)
		part_num = maximum([1, length(available) ÷ Threads.nthreads()])
		chunks = Iterators.partition(available, part_num)
		# println(chunks)
		tasks = map(chunks) do chunk
			Threads.@spawn begin
				total24 = 0
				for next in chunk 
					new_blocked = copy(blocked)
					for cube in available
						(cube < next) && (push!(new_blocked, cube))
					end
					branch_total24 = polycube_counter24(n, [placed; [next]], new_blocked, f)
					total24 += branch_total24
				end
				return total24
			end
		end
		chunk_total24s = fetch.(tasks)
		return sum(chunk_total24s)
	end
end

polycube_counter24(n, placed, f) = polycube_counter24(n, placed, [], f)

function get_available(placed, blocked)
	deltas = [[-1, 0, 0], [0, -1, 0], [0, 0, -1], [0, 0, 1], [0, 1, 0], [1, 0, 0]]
	available = []
	for p in placed, d in deltas
		cand = p+d
		((cand in placed)
		||(cand in blocked)
		||(cand in available)
		||(cand < placed[1])
		||(push!(available, cand)))
	end
	return available
end


L = [[0, 1, 0] [-1, 0, 0] [0, 0, 1]]
U = [[1, 0, 0] [0, 0, -1] [0, 1, 0]]
I = [[1, 0, 0] [0, 1, 0] [0, 0, 1]]

rotations = [I, L, L^2, L^3,
U, U*L, U*L^2, U*L^3,
U^2, U^2*L, U^2*L^2, U^2*L^3,
U^3, U^3*L, U^3*L^2, U^3*L^3,
L*U, L*U*L, L*U*L^2, L*U*L^3,
L*U^3, L*U^3*L, L*U^3*L^2, L*U^3*L^3]

function symmetries(placed)
	rotated = [sort!([M*v for v in placed]) for M in rotations]
	rooted = [[x-s[1] for x in s] for s in rotated]
	syms = length(findall(x -> x==rooted[1], rooted))
	return syms
end


function deal_with_it(placed)
	# println("Thread: ",Threads.threadid())
	# println("polycube = ", placed)
end

for n in 9:9
	root = [0, 0, 0]
	placed = [root]
	@time total24 = polycube_counter24(n, placed, deal_with_it)
	println("With $n there are a total of ", total24/24)
end

