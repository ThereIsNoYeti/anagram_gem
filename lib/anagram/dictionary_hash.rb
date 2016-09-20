class DictionaryHash
#== Class Header =======================================================================================================

#-- Included Modules ---------------------------------------------------------------------------------------------------
  # include ActiveModel::Model

#-- Local Constants ----------------------------------------------------------------------------------------------------
  DEFAULT_DICTIONARY_FILE = Rails.root.join('lib', 'modules', 'dictionary_hash', 'default_dictionary.txt')
  VALID_WORD_REGEXP = /\A[a-z-]+\z/

#-- Plug-in Behaviors --------------------------------------------------------------------------------------------------

#-- Associations -------------------------------------------------------------------------------------------------------

#-- Callbacks ----------------------------------------------------------------------------------------------------------

#-- Validations --------------------------------------------------------------------------------------------------------

#-- Accessors ----------------------------------------------------------------------------------------------------------

#== Singleton Methods ==================================================================================================

#== Public Methods =====================================================================================================
  def initialize(load_file: nil)
    if load_file.present?
      raise ArgumentError.new('Invalid dictionary file') unless import_file(load_file)
    end

    self
  end

  def import_file(load_file=  DEFAULT_DICTIONARY_FILE)
    begin
      File.readlines(load_file.to_s,'r').each {|line| add_word(line.rstrip)}
    rescue Errno::ENOENT
      false
    end
  end

  def size
    storage_hash.size
  end

  def meta_data
    #This is not a great implementation, I would use a database in a real scenario, this is a cheap out
    #I didn't want to use a data store for the sake of a practical to keep things simple
    _flat_store = storage_hash.values.flatten.sort_by {|word| word.to_s.length}
    {
        word_count:          _flat_store.size,
        minimum_word_length: _flat_store.first.length,
        maximum_word_length: _flat_store.last.length,
        median_word_length:  _flat_store[_flat_store.size/2].length,
        average_word_length: BigDecimal(_flat_store.join.length)/_flat_store.size,
    }

  end

  def fetch_word_hash(word, limit_size: nil, exclude_proper_nouns: false)
    return [] unless valid_word?(word)
    return [] if limit_size.present? and limit_size.to_i < 1

    _hash_id = word_hash_id(word)
    if storage_hash[_hash_id].present?
      _words = storage_hash[_hash_id]
      _words = _words.select {|word| word.match(/\A[a-z]/).present?} if exclude_proper_nouns


      return _words.slice(0..limit_size.to_i-1) if limit_size.present?
      _words
    else
      []
    end
  end

  def add_word(word)
    return false unless valid_word?(word)

    _hash_id = word_hash_id(word)
    storage_hash[_hash_id] = []    unless storage_hash[_hash_id].is_a? Array
    storage_hash[_hash_id] << word unless storage_hash[_hash_id].include? word
  end

  def add_words(word_collection)
    word_collection.each {|word| add_word(word)} if word_collection.respond_to?(:each)
  end

  def remove_word(word)
    return false unless valid_word?(word)

    _hash_id = word_hash_id(word)
    storage_hash[_hash_id].delete word if storage_hash[_hash_id].is_a? Array
    storage_hash.delete _hash_id if storage_hash[_hash_id].blank?
    true
  end

  def remove_words(word_collection)
    word_collection.each {|word| remove_word(word)} if word_collection.respond_to?(:each)
  end

  def remove_all_words
    @storage_hash = HashWithIndifferentAccess.new
  end

#== Protected Methods ==================================================================================================

#== Private Methods ====================================================================================================
  private

  def valid_word?(word)
    return true if word.is_a? String and word.match(VALID_WORD_REGEXP).present?
    false
  end

  def word_hash_id(word)
    word.downcase
  end

  def storage_hash
    return @storage_hash if @storage_hash.is_a? Hash
    @storage_hash = HashWithIndifferentAccess.new
  end

end