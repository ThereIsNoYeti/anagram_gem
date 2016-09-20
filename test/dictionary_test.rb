require File.expand_path('../../../config/environment', __FILE__)

require 'active_support'
require 'rails/test_help'

class DictionaryTest < ActiveSupport::TestCase
  test 'Anagram Dictionary Test #00: Initializing default dictionary' do
    dictionary = AnagramHash.new

    assert(dictionary.present?, 'Dictionary was not initialized')
  end

  test 'Anagram Dictionary Test #01: Initializing dictionary from file' do
    _dictionary_file = Dir.pwd.join('default_dictionary.txt')
    dictionary = AnagramHash.new(load_file: _dictionary_file)

    assert(dictionary.present?, 'Dictionary was not initialized')
  end

  test 'Anagram Dictionary Test #02: Initializing dictionary from bad file' do
    _dictionary_file = Dir.pwd.join('bad_dictionary_file.txt')
    assert_raises(ArgumentError) do AnagramHash.new(load_file: _dictionary_file) end
  end

  test 'Anagram Dictionary Test #03: Adding a word' do
    dictionary = AnagramHash.new
    _dictionary_size = dictionary.size

    dictionary.add_word('ruby')

    assert_equal(_dictionary_size + 1, dictionary.size,        'Dictionary size is incorrect!')
    assert_equal(['ruby'], dictionary.fetch_word_hash('ruby'), 'Word failed to fetch correctly!')
  end

  test 'Anagram Dictionary Test #04: Adding a word that already exists!' do
    dictionary = AnagramHash.new
    dictionary.add_word('ruby')

    _dictionary_size = dictionary.size

    dictionary.add_word('ruby')

    assert_equal(_dictionary_size, dictionary.size,            'Dictionary size is incorrect!')
    assert_equal(['ruby'], dictionary.fetch_word_hash('ruby'), 'Word failed to fetch correctly!')
  end

  test 'Anagram Dictionary Test #05: Removing a word' do
    dictionary = AnagramHash.new
    _dictionary_size = dictionary.size

    dictionary.add_word('ruby')

    assert_equal(_dictionary_size + 1, dictionary.size,        'Dictionary size is incorrect!')
    assert_equal(['ruby'], dictionary.fetch_word_hash('ruby'), 'Word failed to fetch correctly!')

    dictionary.remove_word('ruby')

    assert_equal(_dictionary_size, dictionary.size,      'Dictionary size is incorrect!')
    assert_equal([], dictionary.fetch_word_hash('ruby'), 'Word failed to fetch correctly!')
  end

  test 'Anagram Dictionary Test #06: Removing a word that doesn\'t exist' do
    dictionary = AnagramHash.new
    _dictionary_size = dictionary.size

    dictionary.add_word('ruby')

    assert_equal(_dictionary_size + 1, dictionary.size,        'Dictionary size is incorrect!')
    assert_equal(['ruby'], dictionary.fetch_word_hash('ruby'), 'Word failed to fetch correctly!')

    dictionary.remove_word('rubbish')

    assert_equal(_dictionary_size + 1, dictionary.size,        'Dictionary size is incorrect, the word may have been improperly removed!')
    assert_equal(['ruby'], dictionary.fetch_word_hash('ruby'), 'Word failed to fetch correctly!')
  end

  test 'Anagram Dictionary Test #07: Removing some words' do
    dictionary = AnagramHash.new
    _dictionary_size = dictionary.size

    dictionary.add_words %w(ruby yrub byru ubyr)

    assert_equal(_dictionary_size + 1, dictionary.size,      'Dictionary size is incorrect!')

    dictionary.remove_words %w(ruby yrub)

    assert_equal(1, dictionary.size,                         'Dictionary size is incorrect!')
    assert_equal(2, dictionary.fetch_word_hash('ruby').size, 'Word failed to fetch correctly!')
  end

  test 'Anagram Dictionary Test #08: Removing anagram words' do
    dictionary = AnagramHash.new
    _dictionary_size = dictionary.size

    dictionary.add_words %w(ruby yrub byru ubyr)

    assert_equal(_dictionary_size + 1, dictionary.size,      'Dictionary size is incorrect!')

    dictionary.remove_anagram('ruby')

    assert_equal(0, dictionary.size,                         'Dictionary size is incorrect!')
    assert_equal(0, dictionary.fetch_word_hash('ruby').size, 'Word failed to fetch correctly!')
  end

  test 'Anagram Dictionary Test #09: Removing all words' do
    dictionary = AnagramHash.new
    _dictionary_size = dictionary.size

    dictionary.add_words %w(ruby yrub byru ubyr)

    assert_equal(_dictionary_size + 1, dictionary.size,      'Dictionary size is incorrect!')

    dictionary.remove_all_words

    assert_equal(0, dictionary.size,                     'Dictionary size is incorrect!')
    assert_equal([], dictionary.fetch_word_hash('ruby'), 'Word failed to fetch correctly!')
  end

  test 'Anagram Dictionary Test #10: Fetch with multiple anagrams' do
    dictionary = AnagramHash.new
    _dictionary_size = dictionary.size

    dictionary.add_words %w(ruby yrub byru ubyr)

    assert_equal(_dictionary_size + 1, dictionary.size,      'Dictionary size is incorrect!')
    assert_equal(4, dictionary.fetch_word_hash('ruby').size, 'Word failed to fetch correctly, too many or too few results!')
  end

  test 'Anagram Dictionary Test #10.5: Fetch anagrams with multiple anagrams' do
    dictionary = AnagramHash.new
    _dictionary_size = dictionary.size

    dictionary.add_words %w(ruby yrub byru ubyr)

    assert_equal(_dictionary_size + 1, dictionary.size,      'Dictionary size is incorrect!')
    assert_equal(3, dictionary.fetch_anagrams('ruby').size, 'Word failed to fetch correctly, too many or too few results!')
  end

  test 'Anagram Dictionary Test #11: Fetch with multiple anagrams with limit' do
    dictionary = AnagramHash.new
    _dictionary_size = dictionary.size

    dictionary.add_words %w(ruby yrub byru ubyr)

    assert_equal(_dictionary_size + 1, dictionary.size,                     'Dictionary size is incorrect!')
    assert_equal(2, dictionary.fetch_word_hash('ruby', limit_size: 2).size, 'Word failed to fetch correctly, too many or too few results!')
  end

  test 'Anagram Dictionary Test #12: Fetch with multiple anagrams with over-limit' do
    dictionary = AnagramHash.new
    _dictionary_size = dictionary.size

    dictionary.add_words %w(ruby yrub byru ubyr)

    assert_equal(_dictionary_size + 1, dictionary.size,                      'Dictionary size is incorrect!')
    assert_equal(4, dictionary.fetch_word_hash('ruby', limit_size: 10).size, 'Word failed to fetch correctly, too many or too few results!')
  end

  test 'Anagram Dictionary Test #13: Fetch with multiple anagrams with under-limit' do
    dictionary = AnagramHash.new
    _dictionary_size = dictionary.size

    dictionary.add_words %w(ruby yrub byru ubyr)

    assert_equal(_dictionary_size + 1, dictionary.size,                      'Dictionary size is incorrect!')
    assert_equal(0, dictionary.fetch_word_hash('ruby', limit_size: -1).size, 'Word failed to fetch correctly, invalid numbers should not work!')
  end

  test 'Anagram Dictionary Test #14: Meta-Data' do
    dictionary = AnagramHash.new

    dictionary.add_words %w(c ruby yrub byru ubyr)

    assert_equal(5, dictionary.meta_data[:word_count],           'Dictionary word count is incorrect!')
    assert_equal(1, dictionary.meta_data[:minimum_word_length],  'Dictionary minimum word length is incorrect!')
    assert_equal(4, dictionary.meta_data[:maximum_word_length],  'Dictionary maximum word length incorrect!')
    assert_equal(4, dictionary.meta_data[:median_word_length],   'Dictionary median word length is incorrect!')
    assert_equal(3.4, dictionary.meta_data[:average_word_length],  'Dictionary average word legnth is incorrect!')

  end

  test 'Anagram Dictionary Test #15: Ignore proper nouns' do
    dictionary = AnagramHash.new
    _dictionary_size = dictionary.size

    dictionary.add_words %w(Ruby yrub byru ubyr)

    assert_equal(_dictionary_size + 1, dictionary.size,      'Dictionary size is incorrect!')
    assert_equal(3, dictionary.fetch_word_hash('ruby', exclude_proper_nouns: true).size, 'Word failed to fetch correctly, too many or too few results!')
  end

  test 'Anagram Dictionary Test #16: Most anagrams' do
    dictionary = AnagramHash.new

    dictionary.add_words %w(ruby yrub byru ubyr swift tswif ftswi iftsw wifts)

    assert(dictionary.words_with_most_anagrams.include?('swift'),  'Dictionary failed to detect words with most anagrams!')
  end

  test 'Anagram Dictionary Test #17: Exact number of anagrams anagrams' do
    dictionary = AnagramHash.new

    dictionary.add_words %w(ruby yrub byru ubyr swift tswif ftswi iftsw wifts)

    assert(dictionary.words_with_anagram_count(4).include?('ruby'),  'Dictionary failed to detect words with designated number of anagrams!')
  end

end
