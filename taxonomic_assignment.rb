require 'csv'


def belongs_to_rank(pident)
      subspecies  = 99.0
      species     = 98.0
      genus       = 95.0
      family      = 90.0
      order       = 85.0


      return 'subspecies'     if pident >= subspecies
      return 'species'        if pident >= species
      return 'genus'          if pident >= genus
      return 'family'         if pident >= family
      return 'order'          if pident >= order
      return nil
end


def ranking_by(pident)
    subspecies  = 99.0
    species     = 98.0
    genus       = 95.0
    family      = 90.0
    order       = 85.0

    return 5 if pident >= subspecies
    return 4 if pident >= species
    return 3 if pident >= genus
    return 2 if pident >= family
    return 1 if pident >= order
    return 0
end


def change_header(header:, rank:, target_resolution:)
      return nil if rank.nil?


      if target_resolution == 8
            return header if rank == 'subspecies'
            return header.reverse.gsub(/^.*?_/, '').reverse    if rank == 'species'
            return header.reverse.gsub(/^.*?_.*?_/, '').reverse    if rank == 'genus'
            return header.reverse.gsub(/^.*?\|/, '').reverse    if rank == 'family'
            return header.reverse.gsub(/^.*?\|.*?\|/, '').reverse    if rank == 'order'
      elsif target_resolution == 7
            return header if rank == 'subspecies' || rank == 'species'
            return header.reverse.gsub(/^.*?_/, '').reverse    if rank == 'genus'
            return header.reverse.gsub(/^.*?\|/, '').reverse    if rank == 'family'
            return header.reverse.gsub(/^.*?\|.*?\|/, '').reverse    if rank == 'order'
      elsif target_resolution == 6
            return header if rank == 'subspecies' || rank == 'species' || rank == 'genus'
            return header.reverse.gsub(/^.*?\|/, '').reverse    if rank == 'family'
            return header.reverse.gsub(/^.*?\|.*?\|/, '').reverse    if rank == 'order'
      elsif target_resolution == 5
            return header if rank == 'subspecies' || rank == 'species' || rank == 'genus' || rank == 'family'
            return header.reverse.gsub(/^.*?\|.*?\|/, '').reverse    if rank == 'order'
      elsif target_resolution <= 4
            return header if rank == 'subspecies' || rank == 'species' || rank == 'genus' || rank == 'family' || rank == 'order'
      end


      return nil
end


file    = File.open(ARGV.shift, 'r')
csv     = CSV.new(file, col_sep: "\t", liberal_parsing: true, headers: false)


pident_for  = Hash.new
targets_for = Hash.new
csv.each do |row|
      query             = row[0]
      target            = row[1].gsub(/\|$/, '')#.gsub('Metazoa', 'Animalia')
      pident            = row[2].to_f
      length            = row[3].to_i
      num_mismatch      = row[4].to_i
      num_gapopen       = row[5]
      qstart            = row[6]
      qend              = row[7]
      sstart            = row[8]
      s_end             = row[9]
      evalue            = row[10]
      bitscore          = row[11]


      length -= num_mismatch


      target_resolution = target.count('|')
      next if target_resolution == 0


      
      last_part_of_target = target.reverse.match(/^(.*?)\|/).captures.first.reverse
      target_resolution += 1 if last_part_of_target.match?('_')
      rank_after_pident_consideration = ranking_by(pident)


      rank = belongs_to_rank(pident)
      changed_header = change_header(header: target, rank: rank, target_resolution: target_resolution)
      next if changed_header.nil?


      changed_header_resolution = changed_header.count('|')
      last_part_of_changed_header = changed_header.reverse.match(/^(.*?)\|/).captures.first.reverse
      changed_header_resolution += last_part_of_changed_header.count('_')


      if length >= 100
            unless pident_for.key?(query)
                  pident_for[query]       = pident 
                  targets_for[query]      = [[changed_header, pident, length, changed_header_resolution, rank_after_pident_consideration, last_part_of_changed_header]]
                  next
            else
                  targets_for[query].push([changed_header, pident, length, changed_header_resolution, rank_after_pident_consideration, last_part_of_changed_header]) if (pident_for[query] - pident) <= 0.5 
                  next
            end
      end
end


puts "query\ttarget_id\tkingdom\tphylum\tclass\torder\tfamily\tgenus\tspecies\tidentity\tnuc_match"
targets_for.each do |key, value|
      value.sort_by! { |info| [info[3], info[4], info[2], info[1]] }.reverse!
      best_hit = value.first
      resolution = best_hit[3]
      pident = best_hit[1]
      length = best_hit[2]
      best_hit_ary = best_hit.first.split('|')
      best_hit_str = best_hit_ary.join("\t")
      best_hit_str.reverse!.gsub!(/^.*?\t/, '').reverse! if resolution >= 6
      num_ranks = resolution > 5 ? 5 : resolution
      num_missing_ranks = 5 - num_ranks
      tabs = "\t" * num_missing_ranks
      last_part = best_hit.last
      

      genus = last_part.reverse.gsub(/^.*?_.*?_/, '').reverse if resolution == 8
      genus = last_part.reverse.gsub(/^.*?_/, '').reverse if resolution == 7
      genus = last_part if resolution == 6
      genus = '' if resolution < 6


      species = last_part.reverse.match(/^(.*?_.*?)_/).captures.first.reverse if resolution == 8
      species = last_part.reverse.match(/^(.*?)_/).captures.first.reverse if resolution == 7
      species = '' if resolution < 7
      puts "#{key}\t#{best_hit_str}\t#{tabs}#{genus}\t#{species}\t#{pident}\t#{length}"
end