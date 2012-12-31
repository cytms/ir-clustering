# simpleHAC.rb
require_relative 'similarity'
require_relative 'heap'
INPUT_FOLDER = "IRTM_news_files_tfidf_2"
CLUSTER_ARRAY = ARGV
FILE_NUM = 10
p ARGV
# similarity table

#init_i = Array.new
doc_hash = Hash.new
Dir.foreach(INPUT_FOLDER + '/') do |doc|
	next if doc == '.' or doc == '..'
	puts "Hash of #{doc}"
	h = Hash.new
	f = File.open(INPUT_FOLDER + "/" + doc, "r")
	line = f.gets
	while (line = f.gets)
		a,b = line.split("\t")	#a = t_index; b = tf-idf
		h[a] = b.gsub(/\n/, "").to_f
	end
	doc_hash[doc] = h
end
c = Hash.new
(1..FILE_NUM).each{|x|
	tmp = Hash.new
	puts "calculating similarity of #{x}"
	(x..FILE_NUM).each{|y|
		tmp[y] = cosine(doc_hash[x.to_s + ".txt"] , doc_hash[y.to_s + ".txt"])
	}
	#init_i[x] = 1
	c[x] = tmp
}
#p c
f = open("c.txt", "w")
f.write(c)
f.close()
i = Array.new(FILE_NUM + 1){|e| e = 1}
#p i

a = Array.new

(1..FILE_NUM-1).each {|k|
	puts "merge round #{k}"
	argmax_heap = Heap.new
	argmax = Array.new
	(1..FILE_NUM).each{|i_key|
		(i_key+1..FILE_NUM).each{|m_key|
			if i[i_key] == 1 && i[m_key] == 1 
				tmp = Array.new
				tmp << i_key
				tmp << m_key
				tmp << c[i_key][m_key]
				argmax_heap.push(tmp)
			end
		}
	}
	# p argmax_arr.sort_by{|e| e[2]}.reverse!
	argmax = argmax_heap.pop
	i[argmax[1]] = 0
	# p argmax

	c.each{|row_key, row_value|
		row_value.each{|column_key, column_value|
			if column_key == argmax[0] &&  row_key != argmax[1] && column_value < row_value[argmax[1]]
				column_value = row_value[argmax[1]]
			end
		}
	}
	c[argmax[0]].each{|column_key, column_value|
		column_value = c[column_key][argmax[0]]
	}
	a << [argmax[0], argmax[1]]
}
# a = [[1,3],[3,2],...]
f = open("a.txt", "w")
f.write(a)
f.close()
CLUSTER_ARRAY.each{|cluster_number|
	puts "\nprocessing #{cluster_number}.txt..."
	p a
	merge_record = Hash.new
	(1..FILE_NUM).each {|i_key|
		tmp_arr = Array.new
		tmp_arr << i_key
		merge_record[i_key] = tmp_arr
	}

	inverse_k = FILE_NUM - cluster_number.to_i
	(0..inverse_k-1).each {|k|
		puts "round #{k}"
		merge_record[a[k][0]] += merge_record[a[k][1]]
		merge_record.delete(a[k][1])
	}

	p merge_record
	output_text = ""
	merge_record.each{|i_key, i_value|
		i_value.sort.each{|e|
			output_text += e.to_s
			output_text += "\n"
		}
		output_text += "\n"
	}
	# puts output_text
	output_f = open(cluster_number.to_s + "_heap.txt", "w")
	output_f.write(output_text)
	output_f.close()
	f = open(cluster_number.to_s + "_merge.txt", "w")
	f.write(merge_record)
	f.close()

}
#end