class AnagramHash < DictionaryHash
#== Class Header =======================================================================================================

#-- Included Modules ---------------------------------------------------------------------------------------------------

#-- Local Constants ----------------------------------------------------------------------------------------------------

#-- Plug-in Behaviors --------------------------------------------------------------------------------------------------

#-- Associations -------------------------------------------------------------------------------------------------------

#-- Callbacks ----------------------------------------------------------------------------------------------------------

#-- Validations --------------------------------------------------------------------------------------------------------

#-- Accessors ----------------------------------------------------------------------------------------------------------

#== Singleton Methods ==================================================================================================

#== Public Methods =====================================================================================================
  public

  def remove_anagram(word)
    return false unless valid_word?(word)

    _hash_id = word_hash_id(word)
    storage_hash.delete _hash_id

  end

  def fetch_anagrams(word, limit_size: nil, exclude_proper_nouns: false)
    return [] unless valid_word?(word)
    return [] if limit_size.present? and limit_size.to_i < 1

    _hash = fetch_word_hash(word, limit_size: nil, exclude_proper_nouns: exclude_proper_nouns)
    _hash = _hash.select {|_word| _word != word}
    return _hash.slice(0..limit_size.to_i-1) if limit_size.present?

    _hash
  end

  def words_with_most_anagrams
    _sorted_set = storage_hash.values.sort_by {|words| words.size}  #_longest collection = []; sto.values.each {|anagragram_collection| _longest_collection = anagragram_collection if anagragram_collection.size > _longest_collection.size}
    _biggest_set = _sorted_set.last.size
    _sorted_set.select {|words| words.size == _biggest_set}.flatten
  end

  def words_with_anagram_count(number)
    return [] if number.present? and number.to_i < 1

    storage_hash.values.select {|words| words.count == number.to_i}.flatten
  end


#== Protected Methods ==================================================================================================

#== Private Methods ====================================================================================================
  private

  def word_hash_id(word)
    return false unless valid_word?(word)

    word.downcase.chars.sort.join
  end

end