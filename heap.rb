# modified by cytms
# 2013.1.13

class Heap
  def initialize
    @ary = [] # ["file1","file2",similarity]
  end
  
  def clear
    @ary.clear
  end

  def list
    @ary
  end

  def first
    @ary.first
  end
  
  def find(k)
    @ary.index{|x| x.first(x.size-1)==k}
  end

  def delete(k)
    @ary.delete_if{|x| x.first(x.size-1)==k}
  end

  def pop
    return @ary[0]
  ensure # always happen
    @ary[0] = @ary[-1]
    @ary.pop
    down(0)
  end

  def push(obj)
    @ary.push(obj) # push obj at the end of ary
  ensure
    up(@ary.size-1)
  end
  
  private
  def up(n)
    parent = (n - 1) / 2
    return if parent < 0
    return unless @ary[parent].last < @ary[n].last # if use complete link, change to '>'
    @ary[parent], @ary[n] = @ary[n], @ary[parent] # swap
    up(parent) # look forward
  end

  def down(n)
    child = 2 * n + 1
    return if @ary.size <= child
    child += 1 if  @ary[child + 1] && @ary[child].last < @ary[child + 1].last
    return unless @ary[n][1] < @ary[child].last
    @ary[child], @ary[n] = @ary[n], @ary[child]
    down(child)
  end
end


if __FILE__ == $0
  h = Heap.new
  20.times { h.push([1,rand(100)]) }
  h.push([2,1.234])
  h.push([3,0.22])
  h.push([3,2.333])
  p h.list
  h.delete([2])
  p h.list
  h.clear
  p h.list
end