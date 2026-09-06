import 'dart:math';
import '../../../domain/enums/document_type.dart';
import 'text_preprocessor.dart';

class ClassificationResult {
  final DocumentType type;
  final double confidence; // 0.0 - 1.0
  final Map<DocumentType, double> probabilities; // all class probabilities
  
  ClassificationResult({
    required this.type,
    required this.confidence,
    required this.probabilities,
  });
}

class NaiveBayesClassifier {
  // Word frequencies per class
  Map<String, Map<String, int>> _wordCounts = {}; // type -> word -> count
  Map<String, int> _classCounts = {}; // type -> total documents
  Set<String> _vocabulary = {};
  
  // Document frequency (for TF-IDF)
  Map<String, int> _docFreq = {}; // word -> number of documents containing it
  
  int _totalDocuments = 0;
  
  // Laplace smoothing parameter
  static const double _alpha = 1.0;
  
  NaiveBayesClassifier();
  
  /// Classify a text and return result with confidence
  ClassificationResult classify(String text) {
    if (!isTrained) {
      throw Exception('Classifier is not trained');
    }
    
    List<String> tokens = TextPreprocessor.tokenize(text);
    tokens.addAll(TextPreprocessor.generateBigrams(tokens));
    
    Map<DocumentType, double> logProbs = {};
    
    for (var docType in DocumentType.values) {
      String typeStr = docType.name;
      if (!_classCounts.containsKey(typeStr)) continue;
      
      int classDocCount = _classCounts[typeStr] ?? 0;
      double prior = log(classDocCount / _totalDocuments);
      
      double logProb = prior;
      Map<String, int> classWords = _wordCounts[typeStr] ?? {};
      
      int totalWordsInClass = classWords.values.fold(0, (sum, count) => sum + count);
      int vocabSize = _vocabulary.length;
      
      for (String token in tokens) {
        if (_vocabulary.contains(token)) {
          int wordCount = classWords[token] ?? 0;
          double pWordGivenClass = (wordCount + _alpha) / (totalWordsInClass + vocabSize * _alpha);
          
          // TF-IDF Weighting: emphasize discriminative words
          int df = _docFreq[token] ?? 1;
          double idf = log(_totalDocuments / df) + 1.0;
          
          logProb += log(pWordGivenClass) * idf;
        }
      }
      
      logProbs[docType] = logProb;
    }
    
    if (logProbs.isEmpty) {
      throw Exception('Could not classify text');
    }
    
    // Sort and get probabilities (softmax)
    double maxLogProb = logProbs.values.reduce(max);
    Map<DocumentType, double> expProbs = {};
    double sumExp = 0.0;
    
    logProbs.forEach((type, logP) {
      double expP = exp(logP - maxLogProb);
      expProbs[type] = expP;
      sumExp += expP;
    });
    
    Map<DocumentType, double> probabilities = {};
    expProbs.forEach((type, expP) {
      probabilities[type] = expP / sumExp;
    });
    
    var sortedEntries = probabilities.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
      
    DocumentType topClass = sortedEntries.first.key;
    double confidence = sortedEntries.first.value;
    
    if (sortedEntries.length > 1) {
      confidence = sortedEntries[0].value - sortedEntries[1].value;
    }
    
    return ClassificationResult(
      type: topClass,
      confidence: confidence,
      probabilities: probabilities,
    );
  }
  
  /// Train the classifier with labeled samples
  void trainBatch(Map<DocumentType, List<String>> samples) {
    samples.forEach((type, texts) {
      for (String text in texts) {
        update(text, type);
      }
    });
  }
  
  /// Online learning: update model with a single correction
  void update(String text, DocumentType correctType) {
    String typeStr = correctType.name;
    _wordCounts.putIfAbsent(typeStr, () => {});
    
    List<String> tokens = TextPreprocessor.tokenize(text);
    tokens.addAll(TextPreprocessor.generateBigrams(tokens));
    
    // Update document frequencies for TF-IDF
    Set<String> uniqueTokens = tokens.toSet();
    for (String token in uniqueTokens) {
      _docFreq[token] = (_docFreq[token] ?? 0) + 1;
    }
    
    for (String token in tokens) {
      _wordCounts[typeStr]![token] = (_wordCounts[typeStr]![token] ?? 0) + 1;
      _vocabulary.add(token);
    }
    
    _classCounts[typeStr] = (_classCounts[typeStr] ?? 0) + 1;
    _totalDocuments++;
  }
  
  /// Serialize model to JSON for persistence
  Map<String, dynamic> toJson() {
    return {
      'wordCounts': _wordCounts,
      'classCounts': _classCounts,
      'vocabulary': _vocabulary.toList(),
      'docFreq': _docFreq,
      'totalDocuments': _totalDocuments,
    };
  }
  
  /// Deserialize model from JSON
  factory NaiveBayesClassifier.fromJson(Map<String, dynamic> json) {
    var classifier = NaiveBayesClassifier();
    
    classifier._wordCounts = (json['wordCounts'] as Map<String, dynamic>).map(
      (k, v) => MapEntry(k, Map<String, int>.from(v as Map))
    );
    classifier._classCounts = Map<String, int>.from(json['classCounts'] as Map);
    classifier._vocabulary = Set<String>.from(json['vocabulary'] as List);
    
    if (json.containsKey('docFreq')) {
      classifier._docFreq = Map<String, int>.from(json['docFreq'] as Map);
    }
    
    classifier._totalDocuments = json['totalDocuments'] as int;
    
    return classifier;
  }
  

  
  /// Check if model is trained
  bool get isTrained => _totalDocuments > 0;
}



