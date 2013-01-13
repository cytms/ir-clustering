# simpleHAC.rb
require_relative 'similarity'
require_relative 'heap'
INPUT_FOLDER = "IRTM_news_files_tfidf"
# CLUSTER_ARRAY = ARGV
FILE_NUM = 1095
# p ARGV

# read tf-idf files & store in hashes
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

# similarity table
c = Hash.new
p = Array.new(FILE_NUM + 1)

(1..FILE_NUM).each{|x|
	tmp = Hash.new
	tmp_heap = Heap.new
	
	puts "calculating similarity of #{x}"
	(1..FILE_NUM).each{|y|
		tmp_ary = Array.new
		tmp[y] = cosine(doc_hash[x.to_s + ".txt"] , doc_hash[y.to_s + ".txt"])
		tmp_ary << y
		tmp_ary << tmp[y]
		tmp_heap.push(tmp_ary)
	}
	tmp_heap.pop
	p[x] = tmp_heap
	c[x] = tmp
}

f = open("c.txt", "w")
f.write(c)
f.close()

# cluster
i = Array.new(FILE_NUM + 1){|e| e = 1}
a = Array.new
(1..FILE_NUM-1).each { |r|
	tmp_hash = Hash.new
	tmp_array = []
	(1..FILE_NUM).each{|x|
		if i[x] == 1 then 
			tmp_hash[x] = p[x].first
		end
	}
	puts "process A: round #{r}"
	tmp_array = tmp_hash.max_by{|k,v| v.last}
	k1 = tmp_array.first
	k2 = tmp_array.last.first
	a << [k1,k2]
	i[k2] = 0
	p[k1].clear
	p[k2].clear
	(1..FILE_NUM).each{|x|
		if k1 != x && i[x] == 1 then
			p[x].delete([k1])
			p[x].delete([k2])
			if c[k1][x] > c[k2][x] then
				p[x].push([k1,c[k1][x]])
				p[k1].push([x,c[k1][x]])
			else
				p[x].push([k1,c[k2][x]])
				p[k1].push([x,c[k2][x]])
			end
		end
	}
}

f = open("a.txt", "w")
f.write(a)
f.close()

CLUSTER_ARRAY = ARGV

CLUSTER_ARRAY.each{|cluster_number|
	puts "\nprocessing #{cluster_number}.txt..."
	# p a
	merge_record = Hash.new
	(1..FILE_NUM).each {|i_key|
		tmp_arr = Array.new
		tmp_arr << i_key
		merge_record[i_key] = tmp_arr
	}
	p merge_record

	inverse_k = FILE_NUM - cluster_number.to_i
	(0..inverse_k-1).each {|k|
		puts "round #{k}"
		puts "#{merge_record[a[k][0]]} | #{merge_record[a[k][1]]}"
		merge_record[a[k][0]] += merge_record[a[k][1]]

		merge_record.delete(a[k][1])
	}

	# p merge_record
	output_text = ""
	merge_record.each{|i_key, i_value|
		i_value.sort.each{|e|
			output_text += e.to_s
			output_text += "\n"
		}
		output_text += "\n"
	}
	# puts output_text
	output_f = open("patent_" + cluster_number.to_s + "_heap.txt", "w")
	output_f.write(output_text)
	output_f.close()
	f = open("patent_" + cluster_number.to_s + "_merge.txt", "w")
	f.write(merge_record)
	f.close()
}