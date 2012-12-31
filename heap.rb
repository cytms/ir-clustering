# heap.rb
class Heap
  def initialize
    @ary = []
  end

  def pop
    return @ary[0]
  ensure
    @ary[0] = @ary[-1]
    @ary.pop
    down(0)
  end

  def push(obj)
    @ary.push(obj)
  ensure
    up(@ary.size-1)
  end
  
  private
  def up(n)
    parent = (n - 1) / 2
    return if parent < 0
    return unless @ary[parent][2] < @ary[n][2]
    @ary[parent], @ary[n] = @ary[n], @ary[parent]
    up(parent)
  end

  def down(n)
    child = 2 * n + 1
    return if @ary.size <= child
    child += 1 if  @ary[child + 1] && @ary[child][2] < @ary[child + 1][2]
    return unless @ary[n][2] < @ary[child][2]
    @ary[child], @ary[n] = @ary[n], @ary[child]    
    down(child)
  end
end


if __FILE__ == $0
  h = Heap.new
  100.times { h.push([1,2,rand(100)]) }
  ary = []
  while it = h.pop
    ary << it
  end
  p ary
end