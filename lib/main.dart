import 'dart:io';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Document Text Extractor',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Document Text Extractor'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class DocumentData {
  final String? companyName;
  final String? location;
  final String? contactInfo;
  final String? vehicleNumber;
  final String? driverIc;
  final String? driverName;
  final String? company;
  final String? trailerNumber;
  final String? deliveryNote;
  final String? entryDate;
  final String? entryTime;
  final String? exitDate;
  final String? exitTime;
  final Map<String, String> additionalFields;

  const DocumentData({
    this.companyName,
    this.location,
    this.contactInfo,
    this.vehicleNumber,
    this.driverIc,
    this.driverName,
    this.company,
    this.trailerNumber,
    this.deliveryNote,
    this.entryDate,
    this.entryTime,
    this.exitDate,
    this.exitTime,
    this.additionalFields = const {},
  });

  // Convert to JSON map
  Map<String, dynamic> toJson() {
    return {
      'companyName': companyName,
      'location': location,
      'contactInfo': contactInfo,
      'vehicleNumber': vehicleNumber,
      'driverIc': driverIc,
      'driverName': driverName,
      'company': company,
      'trailerNumber': trailerNumber,
      'deliveryNote': deliveryNote,
      'entryDate': entryDate,
      'entryTime': entryTime,
      'exitDate': exitDate,
      'exitTime': exitTime,
      'additionalFields': additionalFields,
    };
  }
  
  // Add a copyWith method for efficient updates
  DocumentData copyWith({
    String? companyName,
    String? location,
    String? contactInfo,
    String? vehicleNumber,
    String? driverIc,
    String? driverName,
    String? company,
    String? trailerNumber,
    String? deliveryNote, 
    String? entryDate,
    String? entryTime,
    String? exitDate,
    String? exitTime,
    Map<String, String>? additionalFields,
  }) {
    return DocumentData(
      companyName: companyName ?? this.companyName,
      location: location ?? this.location,
      contactInfo: contactInfo ?? this.contactInfo,
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      driverIc: driverIc ?? this.driverIc,
      driverName: driverName ?? this.driverName,
      company: company ?? this.company,
      trailerNumber: trailerNumber ?? this.trailerNumber,
      deliveryNote: deliveryNote ?? this.deliveryNote,
      entryDate: entryDate ?? this.entryDate,
      entryTime: entryTime ?? this.entryTime,
      exitDate: exitDate ?? this.exitDate,
      exitTime: exitTime ?? this.exitTime,
      additionalFields: additionalFields ?? this.additionalFields,
    );
  }
}

class DocumentField {
  final String label;
  final String value;
  
  const DocumentField({required this.label, required this.value});
}

class _MyHomePageState extends State<MyHomePage> {
  File? _file;
  String? _extractedText;
  bool _isImage = false;
  String? _fileName;
  bool _isProcessing = false;
  DocumentData? _documentData;
  List<TextEditingController> _headerTextControllers = [];
  List<TextEditingController> _editableTextControllers = [];

  void _handlePickedImage(XFile pickedFile) async {
    setState(() {
      _isProcessing = true;
      _file = File(pickedFile.path);
      _fileName = pickedFile.name;
      _isImage = true;
      _extractedText = null;
    });
    
    await _extractTextFromImage(_file!);
    
    setState(() {
      _isProcessing = false;
    });
  }

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () async {
                  Navigator.of(context).pop();
                  final pickedFile = await ImagePicker().pickImage(
                    source: ImageSource.gallery,
                    imageQuality: 100,
                  );
                  if (pickedFile != null) {
                    _handlePickedImage(pickedFile);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () async {
                  Navigator.of(context).pop();
                  final pickedFile = await ImagePicker().pickImage(
                    source: ImageSource.camera,
                    imageQuality: 100,
                  );
                  if (pickedFile != null) {
                    _handlePickedImage(pickedFile);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Optimized _extractTextFromImage function
  Future<void> _extractTextFromImage(File imageFile) async {
    final inputImage = InputImage.fromFilePath(imageFile.path);
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    
    try {
      final recognizedText = await textRecognizer.processImage(inputImage);
      _processExtractedText(recognizedText.text);
    } catch (e) {
      setState(() {
        _extractedText = "Error extracting text: ${e.toString()}";
      });
      debugPrint("Error in text extraction: $e");
    } finally {
      textRecognizer.close();
    }
  }

  List<String> preprocessOcrLines(List<String> rawLines) {
    // Log raw input with less string concatenation
    debugPrint("==== RAW OCR LINES ====");
    for (int i = 0; i < rawLines.length; i++) {
      debugPrint('[$i] ${rawLines[i]}');
    }
  
    // First, identify any lines that contain field:value pairs
    final structuredLines = <Map<String, dynamic>>[];
  
    for (int i = 0; i < rawLines.length; i++) {
      final line = rawLines[i];
      
      // Check if this is a field:value pair
      if (line.contains(':')) {
        final colonIndex = line.indexOf(':');
        final field = line.substring(0, colonIndex).trim();
        final value = line.substring(colonIndex + 1).trim();
        
        structuredLines.add({
          'lineIndex': i,
          'type': 'field',
          'original': line,
          'field': field,
          'value': value,
          'colonPos': colonIndex,
        });
      } else {
        // If not a field:value pair, it could be just a field name or just a value
        final isLikelyFieldName = isFieldNamePattern(line);
        
        structuredLines.add({
          'lineIndex': i,
          'type': isLikelyFieldName ? 'potentialField' : 'text',
          'original': line,
        });
      }
    }
  
    // Process structured lines to improve field-value associations
    final improved = <String>[];
    
    // First, add all complete field:value pairs
    for (final item in structuredLines) {
      if (item['type'] == 'field' && item['value'].isNotEmpty) {
        improved.add('${item['field']}: ${item['value']}');
      }
    }
  
    // Now handle potential field names without values
    for (int i = 0; i < structuredLines.length; i++) {
      final current = structuredLines[i];
      
      // If this is a field without a value, try to find a matching value
      if (current['type'] == 'field' && current['value'].isEmpty) {
        final fieldName = current['field'];
        bool valueFound = false;
        
        // Look ahead at the next line to find a potential value
        if (i + 1 < structuredLines.length) {
          final next = structuredLines[i + 1];
          
          // If next item is plain text (not a field), it might be our value
          if (next['type'] == 'text') {
            improved.add('$fieldName: ${next['original']}');
            valueFound = true;
            // Skip this item in the next iteration since we used it
            structuredLines[i + 1]['processed'] = true;
          }
        }
      
        // If no value found using the next line, try spatial matching
        if (!valueFound) {
          // Find values that might match based on column position
          final colonPos = current['colonPos'] as int;
          
          // Look for values with similar column position
          for (int j = 0; j < structuredLines.length; j++) {
            if (i == j || structuredLines[j]['processed'] == true) continue;
            
            final other = structuredLines[j];
            
            // If this is a field:value pair with a value and similar column position
            if (other['type'] == 'field' && 
                other['value'].isNotEmpty && 
                other['colonPos'] != null &&
                (other['colonPos'] - colonPos).abs() < 5) {
              
              improved.add('$fieldName: ${other['value']}');
              valueFound = true;
              break;
            }
          }
        }
      
        // If still no value found, add as field name without value
        if (!valueFound) {
          improved.add('$fieldName: Not Detected');
        }
      }
    }
  
    // Process potential field names (lines that look like field names but don't have colons)
    for (int i = 0; i < structuredLines.length; i++) {
      final current = structuredLines[i];
      
      if (current['type'] == 'potentialField' && current['processed'] != true) {
        final potentialField = current['original'];
        bool valueFound = false;
        
        // Look at the next line to find a potential value
        if (i + 1 < structuredLines.length) {
          final next = structuredLines[i + 1];
          
          // If next item is plain text (not a field), it might be our value
          if (next['type'] == 'text' && next['processed'] != true) {
            improved.add('$potentialField: ${next['original']}');
            valueFound = true;
            // Mark as processed
            structuredLines[i + 1]['processed'] = true;
          }
        }
      
        // If no value found, add field without value
        if (!valueFound) {
          // Only add if it's a known field pattern
          if (isKnownFieldPattern(potentialField)) {
            improved.add('$potentialField: Not Detected');
          } else {
            // Otherwise just add the text as is
            improved.add(potentialField);
          }
        }
      }
      // Add remaining text lines that haven't been processed
      else if (current['type'] == 'text' && current['processed'] != true) {
        improved.add(current['original']);
      }
    }
  
    // Add known fields that might be missing
    final requiredFields = <String>[
      'NOMBOR KENDERAAN',
      'K.P. PEMANDU',
      'NAMA PEMANDU',
      'SYARIKAT',
    ];

    for (final field in requiredFields) {
      final fieldPrefix = '${field.toUpperCase()}:';
      bool found = improved.any((line) => line.toUpperCase().startsWith(fieldPrefix));
      if (!found) {
        improved.add('$field: Not Detected');
      }
    }
  
    // Log the preprocessed result
    debugPrint("==== PREPROCESSED OCR LINES ====");
    for (int i = 0; i < improved.length; i++) {
      debugPrint('[$i] ${improved[i]}');
    }
  
    return improved;
  }

  // Check if a string matches common field name patterns
  bool isFieldNamePattern(String text) {
    // Common field name patterns - use a Set for faster lookups
    final fieldPatterns = <String>{
      'NOMBOR', 'NAMA', 'K.P.', 'SYARIKAT', 'TARIKH', 'MASA', 
      'KOD', 'SUB', 'TRAILER', 'NOTA', 'DRIVER', 'COMPANY',
      'ENTRY', 'EXIT', 'DATE', 'TIME', 'VEHICLE'
    };
    
    final upperText = text.toUpperCase();
    return fieldPatterns.any((pattern) => upperText.contains(pattern));
  }

  // Check if a string is a known important field name
  bool isKnownFieldPattern(String text) {
    // List of known important field names - use a Set for faster lookups
    final knownFields = <String>{
      'NOMBOR KENDERAAN', 'NO. KENDERAAN', 'NO KENDERAAN',
      'K.P. PEMANDU', 'NO. K/P', 'IC NO', 'K.P PEMANDU',
      'NAMA PEMANDU', 'PEMANDU',
      'SYARIKAT', 'COMPANY',
      'NOMBOR TRAILER', 'NO. TRAILER', 'TRAILER',
      'NOTA HANTARAN', 'ARAHAN ANGKUT',
      'TARIKH MASUK', 'ENTRY DATE',
      'MASA MASUK', 'ENTRY TIME',
      'TARIKH KELUAR', 'EXIT DATE',
      'MASA KELUAR', 'EXIT TIME',
      'MUDA', 'LAMA', 'PERAM', 'DURA', 'MENGKAL', 'KOSONG', 
      'PANJANG', 'BUSUK', 'KOTOR', 'S/TIKUS', 'P/T', 'BAS', 'MENG'
    };
    
    final upperText = text.toUpperCase();
    return knownFields.any((field) => upperText.contains(field));
  }

  // Helper function to check if a string contains any field name
  bool containsAnyFieldName(String text, Map<String, List<String>> fieldMappings) {
    final upperText = text.toUpperCase();
    
    for (final fieldNames in fieldMappings.values) {
      for (final fieldName in fieldNames) {
        if (upperText.contains(fieldName.toUpperCase())) {
          return true;
        }
      }
    }
    return false;
  }

  // Optimized extractKeyFields function
  Map<String, String> extractKeyFields(List<String> rawLines) {
    final result = <String, String>{};
    
    // Define the key fields we need to extract with their possible variations
    // Use a Map with String keys for better lookup performance
    final keyFieldMappings = {
      'NOMBOR KENDERAAN': ['NOMBOR KENDERAAN', 'NO. KENDERAAN', 'NO KENDERAAN', 'NOMBOR KENDERAAN :'],
      'K.P. PEMANDU': ['K.P. PEMANDU', 'NO. K/P', 'IC NO', 'K.P PEMANDU', 'K.P. PEMANDU :'],
      'NAMA PEMANDU': ['NAMA PEMANDU', 'NAMA PEMANDU :'],
      'SYARIKAT': ['SYARIKAT', 'COMPANY', 'SYARIKAT :'],
      'NOMBOR TRAILER': ['NOMBOR TRAILER', 'NO. TRAILER', 'TRAILER', 'NOMBOR TRAILER :'],
      'NOTA HANTARAN/ARAHAN ANGKUT': ['NOTA HANTARAN/ARAHAN ANGKUT', 'NOTA HANTARAN', 'ARAHAN ANGKUT', 'NOTA HANTARAN :'],
      'TARIKH MASUK': ['TARIKH MASUK', 'ENTRY DATE', 'TARIKH MASUK :'],
      'MASA MASUK': ['MASA MASUK', 'ENTRY TIME', 'MASA MASUK :']
    };
  
    // Initialize all fields to empty string at once
    for (var key in keyFieldMappings.keys) {
      result[key] = '';
    }
  
    // Cache regular expressions for better performance
    final vehicleRegex = RegExp(r'W[A-Z][0-9]{3,4}[A-Z]?');
    final icRegex = RegExp(r'[0-9]{12}');
    final dateRegex = RegExp(r'\d{2}/\d{2}/\d{4}');
    final timeRegex = RegExp(r'\d{2}:\d{2}:\d{2}');
    final deliveryNoteRegex = RegExp(r'^\d{4}$');
    final trailerRegex = RegExp(r'T/[A-Z][0-9]{3,5}');
  
    // Convert raw lines to uppercase once for better performance
    final upperLines = List<String>.generate(
      rawLines.length, 
      (index) => rawLines[index].toUpperCase()
    );
    
    // First pass: Look for exact field:value patterns
    for (int i = 0; i < rawLines.length; i++) {
      final line = rawLines[i];
      final upperLine = upperLines[i];
      
      // Scan each line for multiple field patterns at once
      for (final field in keyFieldMappings.keys) {
        for (final pattern in keyFieldMappings[field]!) {
          final upperPattern = pattern.toUpperCase();
          
          // Case 1: Pattern followed by colon and value
          final searchPattern = '$upperPattern:';
          int patternIndex = upperLine.indexOf(searchPattern);
          if (patternIndex >= 0) {
            final valueStartIdx = patternIndex + searchPattern.length;
            
            if (valueStartIdx < line.length) {
              final value = line.substring(valueStartIdx).trim();
              if (value.isNotEmpty) {
                result[field] = value;
                break;
              }
            }
          }
          // Case 2: Pattern and colon are together without space
          else {
            final patternWithoutSpace = '${upperPattern.replaceAll(' :', ':')}:';
            patternIndex = upperLine.indexOf(patternWithoutSpace);
            if (patternIndex >= 0) {
              final valueStartIdx = patternIndex + patternWithoutSpace.length;
              
              if (valueStartIdx < line.length) {
                final value = line.substring(valueStartIdx).trim();
                if (value.isNotEmpty) {
                  result[field] = value;
                  break;
                }
              }
            }
          }
        }
      }
    }
  
    // Field-specific extraction for common patterns - use cached regex
    
    // Vehicle Number
    if (result['NOMBOR KENDERAAN']!.isEmpty) {
      for (final line in rawLines) {
        final match = vehicleRegex.stringMatch(line);
        if (match != null) {
          result['NOMBOR KENDERAAN'] = match;
          break;
        }
      }
    }
    
    // Driver IC
    if (result['K.P. PEMANDU']!.isEmpty) {
      for (final line in rawLines) {
        final match = icRegex.stringMatch(line);
        if (match != null) {
          result['K.P. PEMANDU'] = match;
          break;
        }
      }
    }
  
    // Driver Name
    if (result['NAMA PEMANDU']!.isEmpty) {
      for (final line in rawLines) {
        final upperLine = line.toUpperCase();
        if ((upperLine.contains('BIN') || upperLine.contains('BINTI')) && !line.contains(':')) {
          result['NAMA PEMANDU'] = line.trim();
          break;
        }
      }
    }
  
    // Company
    if (result['SYARIKAT']!.isEmpty) {
      // First try direct match
      bool syarikatFound = false;
      for (final line in rawLines) {
        if (line.toUpperCase().contains('SYARIKAT') && line.contains(':')) {
          final colonPos = line.indexOf(':');
          if (colonPos >= 0 && colonPos + 1 < line.length) {
            final value = line.substring(colonPos + 1).trim();
            if (value.contains('FELDA JENGKA')) {
              result['SYARIKAT'] = value;
              syarikatFound = true;
              break;
            }
          }
        }
      }
      
      // If not found, try FELDA JENGKA pattern
      if (!syarikatFound) {
        for (final line in rawLines) {
          if (line.contains('FELDA JENGKA 4') && 
              !line.contains('PUSAT') && 
              !line.contains('D/A') &&
              !line.contains('Palm Industries')) {
            
            result['SYARIKAT'] = 'FELDA JENGKA 4';
            syarikatFound = true;
            break;
          }
        }
      }
    
      // Last resort - context search
      if (!syarikatFound && rawLines.any((line) => line.contains('PENERIMAAN BTS FELDA/FPSB/FTP/FASSB'))) {
        result['SYARIKAT'] = 'FELDA JENGKA 4';
      }
    }
  
    // Trailer Number
    if (result['NOMBOR TRAILER']!.isEmpty) {
      for (final line in rawLines) {
        if (line.contains('T/A') || trailerRegex.hasMatch(line)) {
          final match = trailerRegex.stringMatch(line);
          result['NOMBOR TRAILER'] = match ?? line.trim();
          break;
        }
      }
    }
  
    // Delivery Note
    if (result['NOTA HANTARAN/ARAHAN ANGKUT']!.isEmpty) {
      for (final line in rawLines) {
        if (line.contains('NOTA') || line.contains('ARAHAN') || line.contains('HANTARAN')) {
          if (line.contains(':')) {
            final colonPos = line.indexOf(':');
            final value = line.substring(colonPos + 1).trim();
            if (value.isNotEmpty && RegExp(r'^\d+$').hasMatch(value)) {
              result['NOTA HANTARAN/ARAHAN ANGKUT'] = value;
              break;
            }
          }
        }
      }
    
      // If still empty, try a different approach
      if (result['NOTA HANTARAN/ARAHAN ANGKUT']!.isEmpty) {
        for (final line in rawLines) {
          final trimmed = line.trim();
          if (deliveryNoteRegex.hasMatch(trimmed)) {
            result['NOTA HANTARAN/ARAHAN ANGKUT'] = trimmed;
            break;
          }
        }
      }
    }
  
    // Entry Date and Time
    bool entryDateFound = false;
    bool entryTimeFound = false;
    
    for (final line in rawLines) {
      final upperLine = line.toUpperCase();
      
      // Look for Entry Date
      if (!entryDateFound && upperLine.contains('TARIKH MASUK')) {
        if (line.contains(':')) {
          final colonPos = line.indexOf(':');
          final value = line.substring(colonPos + 1).trim();
          
          if (dateRegex.hasMatch(value)) {
            result['TARIKH MASUK'] = dateRegex.stringMatch(value)!;
            entryDateFound = true;
          } else if (value.isNotEmpty) {
            result['TARIKH MASUK'] = value;
            entryDateFound = true;
          }
        }
      } 
      // Look for standalone date that might be entry date
      else if (!entryDateFound && dateRegex.hasMatch(line) && !upperLine.contains('KELUAR')) {
        result['TARIKH MASUK'] = dateRegex.stringMatch(line)!;
        entryDateFound = true;
      }
    
      // Look for Entry Time
      if (!entryTimeFound && upperLine.contains('MASA MASUK')) {
        if (line.contains(':')) {
          final lastColonPos = line.lastIndexOf(':');
          if (lastColonPos > upperLine.indexOf('MASA MASUK')) {
            final value = line.substring(lastColonPos + 1).trim();
            
            if (timeRegex.hasMatch(value) || RegExp(r'\d{2}:\d{2}').hasMatch(value)) {
              result['MASA MASUK'] = value;
              entryTimeFound = true;
            } else if (value.isNotEmpty) {
              result['MASA MASUK'] = value;
              entryTimeFound = true;
            }
          } else if (timeRegex.hasMatch(line)) {
            result['MASA MASUK'] = timeRegex.stringMatch(line)!;
            entryTimeFound = true;
          }
        }
      } 
      // Look for standalone time that might be entry time
      else if (!entryTimeFound && 
              line.contains(':') && 
              timeRegex.hasMatch(line) && 
              !upperLine.contains('TEL') && 
              !upperLine.contains('FAX') &&
              !upperLine.contains('KELUAR')) {
        result['MASA MASUK'] = timeRegex.stringMatch(line)!;
        entryTimeFound = true;
      }
      
      // Exit early if we found both date and time
      if (entryDateFound && entryTimeFound) break;
    }
    
    return result;
  }

  // Optimized _processExtractedText function
  void _processExtractedText(String text) {
    final List<String> rawLines = text
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();

    // Extract basic document information
    String? companyName;
    List<String> locationLines = [];
    String? contactInfo;
    String? gatePassTitle;
    
    // Use more efficient data structures
    final Set<String> companyKeywords = {'FGV', 'Palm Industries'};
    final Set<String> locationKeywords = {'PUSAT', 'FELDA', 'MARAN', 'PAHANG', 'D/A'};
    final Set<String> contactKeywords = {'Tel', 'Fax'};
    final Set<String> gatePassKeywords = {'GATEPASS', 'GATE PASS', 'G A T E P A S S', 'GAT EPA SS'};
    
    // Look for company name (usually in the first few lines)
    for (int i = 0; i < math.min(5, rawLines.length); i++) {
      if (companyKeywords.any((keyword) => rawLines[i].contains(keyword))) {
        companyName = rawLines[i];
        break;
      }
    }
  
    // Extract location information with Set-based filtering
    for (String line in rawLines) {
      if (locationKeywords.any((keyword) => line.contains(keyword)) && 
          !line.contains(':') && 
          !line.contains('NOMBOR') && 
          !line.contains('HANTARAN')) {
        locationLines.add(line);
      }
    }
    
    // Extract contact information with Set-based filtering
    for (String line in rawLines) {
      if (contactKeywords.any((keyword) => line.contains(keyword))) {
        contactInfo = line;
        break;
      }
    }
  
    // Extract gate pass title with Set-based filtering
    for (String line in rawLines) {
      if (gatePassKeywords.any((keyword) => line.contains(keyword))) {
        gatePassTitle = "GATEPASS"; // Normalize all variations
        break;
      }
    }

    // Use optimized extraction for key fields
    Map<String, String> keyFields = extractKeyFields(rawLines);
    
    // Process additional fields with improved efficiency
    final Map<String, String> additionalFields = {
      "MUDA": "",
      "(P/T)": "",
      "LAMA": "",
      "PERAM": "",
      "DURA": "",
      "MENGKAL": "",
      "KOSONG": "",
      "PANJANG": "",
      "BUSUK": "",
      "KOTOR": "",
      "S/TIKUS": "",
      "B/A": ""
    };
  
    // Use a single pass approach for additional fields
    final Set<String> fieldKeys = additionalFields.keys.toSet();
    for (String line in rawLines) {
      for (String key in fieldKeys) {
        if (line.contains(key)) {
          int keyIndex = line.indexOf(key);
          if (keyIndex + key.length < line.length) {
            String rest = line.substring(keyIndex + key.length).trim();
            if (rest.startsWith(':')) {
              String value = rest.substring(1).trim();
              if (value.isNotEmpty) {
                additionalFields[key] = value;
              }
            }
          }
        }
      }
    }
  
    // Create formatted output text with fewer allocations
    List<String> headerLines = [];
    List<String> editableKeyFields = [];
    
    // Add header info (non-editable)
    headerLines.add(gatePassTitle ?? "GATEPASS");
    headerLines.addAll(locationLines);
    if (contactInfo != null) {
      headerLines.add(contactInfo);
    }
    
    // Add the key fields that will be editable - use more efficient StringBuilder pattern
    final keyFieldNames = [
      "NOMBOR KENDERAAN",
      "K.P. PEMANDU",
      "NAMA PEMANDU",
      "SYARIKAT",
      "NOMBOR TRAILER",
      "NOTA HANTARAN/ARAHAN ANGKUT"
    ];
    
    for (String fieldName in keyFieldNames) {
      editableKeyFields.add("$fieldName: ${keyFields[fieldName] ?? ''}");
    }
  
    // Extract and add dates and times
    String entryDate = keyFields['TARIKH MASUK'] ?? "";
    String entryTime = keyFields['MASA MASUK'] ?? "";
    String exitDate = "", exitTime = "";
    
    editableKeyFields.add("TARIKH MASUK: $entryDate");
    editableKeyFields.add("MASA MASUK: $entryTime");
    editableKeyFields.add("TARIKH KELUAR: $exitDate");
    editableKeyFields.add("MASA KELUAR: $exitTime");
    
    // Add additional fields
    for (MapEntry<String, String> entry in additionalFields.entries) {
      editableKeyFields.add("${entry.key}: ${entry.value}");
    }
  
    // Create DocumentData object with the extracted information
    _documentData = DocumentData(
      companyName: companyName,
      location: locationLines.join('\n'),
      contactInfo: contactInfo,
      vehicleNumber: keyFields['NOMBOR KENDERAAN'],
      driverIc: keyFields['K.P. PEMANDU'],
      driverName: keyFields['NAMA PEMANDU'], 
      company: keyFields['SYARIKAT'],
      trailerNumber: keyFields['NOMBOR TRAILER'],
      deliveryNote: keyFields['NOTA HANTARAN/ARAHAN ANGKUT'],
      entryDate: entryDate,
      entryTime: entryTime,
      exitDate: exitDate,
      exitTime: exitTime,
      additionalFields: additionalFields,
    );
  
    // Combine header and key fields for complete text
    setState(() {
      _extractedText = [...headerLines, ...editableKeyFields].join('\n');
      
      // Create text controllers with fewer allocations
      _headerTextControllers = List.generate(
        headerLines.length, 
        (index) => TextEditingController(text: headerLines[index])
      );
      
      _editableTextControllers = List.generate(
        editableKeyFields.length, 
        (index) => TextEditingController(text: editableKeyFields[index])
      );
    });
  }

  void _copyToClipboard() {
    if (_extractedText != null && _extractedText!.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: _extractedText!));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Text copied to clipboard')),
      );
    }
  }

  Future<void> _saveAsJson() async {
    if (_documentData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No data to save')),
      );
      return;
    }

    // Create a map with only the key fields
    final Map<String, dynamic> keyFieldsOnly = {
      'vehicleNumber': _documentData!.vehicleNumber,
      'driverIc': _documentData!.driverIc,
      'driverName': _documentData!.driverName,
      'company': _documentData!.company,
      'trailerNumber': _documentData!.trailerNumber,
      'deliveryNote': _documentData!.deliveryNote,
      'entryDate': _documentData!.entryDate,
      'entryTime': _documentData!.entryTime,
      'exitDate': _documentData!.exitDate,
      'exitTime': _documentData!.exitTime,
      'additionalFields': _documentData!.additionalFields,
    };
    
    // Print the JSON to the debug console (for verification)
    final JsonEncoder encoder = JsonEncoder.withIndent('  ');
    final String prettyJson = encoder.convert(keyFieldsOnly);
    
    print("==== KEY FIELDS JSON DATA ====");
    print(prettyJson);

    // Create JSON string for saving
    final jsonString = jsonEncode(keyFieldsOnly);
    
    // Get the temporary directory
    final directory = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final fileName = 'document_data_$timestamp.json';
    final filePath = '${directory.path}/$fileName';
    
    // Write the JSON to a file
    final file = File(filePath);
    await file.writeAsString(jsonString, flush: true);

    // Share the file
    await Share.shareXFiles(
      [XFile(filePath)],
      text: 'Document Data JSON',
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('JSON file created and shared')),
    );
  }

  // Optimized _updateFieldValue function using copyWith
  void _updateFieldValue(String fieldName, String value) {
    if (_documentData == null) return;
    
    // Map the field name to the correct property in DocumentData
    switch (fieldName.toUpperCase()) {
      case 'NOMBOR KENDERAAN':
        _documentData = _documentData!.copyWith(vehicleNumber: value);
        break;
      case 'K.P PEMANDU':
      case 'K.P. PEMANDU':
        _documentData = _documentData!.copyWith(driverIc: value);
        break;
      case 'NAMA PEMANDU':
        _documentData = _documentData!.copyWith(driverName: value);
        break;
      case 'SYARIKAT':
        _documentData = _documentData!.copyWith(company: value);
        break;  
      case 'NOMBOR TRAILER':
        _documentData = _documentData!.copyWith(trailerNumber: value);
        break;  
      case 'NOTA HANTARAN/ARAHAN ANGKUT':
        _documentData = _documentData!.copyWith(deliveryNote: value);
        break;
      case 'TARIKH MASUK':
        _documentData = _documentData!.copyWith(entryDate: value);
        break;
      case 'MASA MASUK':
        _documentData = _documentData!.copyWith(entryTime: value);
        break;
      case 'TARIKH KELUAR':
        _documentData = _documentData!.copyWith(exitDate: value);
        break;
      case 'MASA KELUAR':
        _documentData = _documentData!.copyWith(exitTime: value);
        break;      
      default:

      // Handle additional fields
      if (_documentData!.additionalFields.containsKey(fieldName)) {
        Map<String, String> updatedFields = Map.from(_documentData!.additionalFields);
        updatedFields[fieldName] = value;
        _documentData = _documentData!.copyWith(
          additionalFields: updatedFields
        );
      }
      break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          if (_extractedText != null && _extractedText!.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.copy),
              onPressed: _copyToClipboard,
              tooltip: 'Copy text',
            ),
          if (_documentData != null)
            IconButton(
              icon: const Icon(Icons.save_alt),
              onPressed: _saveAsJson,
              tooltip: 'Save as JSON',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Center(
                  child: SizedBox(
                    width: 180, // adjust width as needed
                    height: 45, // adjust height as needed
                    child: ElevatedButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.document_scanner),
                      label: const Text('Scan Document'),
                      style: ElevatedButton.styleFrom(
                        textStyle: const TextStyle(fontSize: 14),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          
            if (_file != null && _isImage)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                      child: Image.file(_file!, fit: BoxFit.cover),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'File: $_fileName',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          
            if (_file != null && !_isImage)
              Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      const Icon(Icons.picture_as_pdf, size: 28, color: Colors.red),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'File: $_fileName',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          
            if (_isProcessing)
              const Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text("Processing document..."),
                  ],
                ),
              )
            else if (_headerTextControllers.isNotEmpty || _editableTextControllers.isNotEmpty) ...[
              // Combined container for both header and key fields
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 1,
                      blurRadius: 3,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header section
                    if (_headerTextControllers.isNotEmpty) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          //color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: List.generate(_headerTextControllers.length, (index) {
                            return Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 8.0),
                              child: Text(
                                _headerTextControllers[index].text,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: index == 0 ? FontWeight.bold : FontWeight.normal,
                                  color: index == 0 ? Colors.deepPurple : Colors.black87,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            );
                          }),
                        ),
                      ),
                      const Divider(thickness: 1.5, color: Colors.black45),
                    ],
                  
                    // Key fields section
                    if (_editableTextControllers.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Column(
                        children: List.generate(_editableTextControllers.length, (index) {
                          // Parse the text to separate label and value
                          String fullText = _editableTextControllers[index].text;
                          int colonIndex = fullText.indexOf(':');
                          String label = colonIndex > 0 ? fullText.substring(0, colonIndex + 1) : fullText;
                          String value = colonIndex > 0 && colonIndex + 1 < fullText.length ? 
                              fullText.substring(colonIndex + 1).trim() : "";
                          
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Non-editable label
                                Expanded(
                                  flex: 2,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade200,
                                      border: Border.all(color: Colors.grey.shade400),
                                      borderRadius: const BorderRadius.horizontal(left: Radius.circular(4)),
                                    ),
                                    child: Text(
                                      label,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                // Editable value
                                Expanded(
                                  flex: 3,
                                  child: TextFormField(
                                    initialValue: value,
                                    onChanged: (newValue) {
                                      // Update the corresponding value in the document data
                                      _updateFieldValue(label.trim().replaceAll(':', ''), newValue);
                                    },
                                    decoration: InputDecoration(
                                      border: const OutlineInputBorder(
                                        borderRadius: BorderRadius.horizontal(right: Radius.circular(4)),
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                                      filled: true,
                                      fillColor: Colors.white,
                                    ),
                                    style: const TextStyle(fontSize: 15),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ),
                    ],
                  ],
                ),
              ),
              if (_documentData != null) ...[
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _saveAsJson,
                  icon: const Icon(Icons.save),
                  label: const Text('Save to JSON'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                    textStyle: const TextStyle(fontSize: 16),
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ]
            ] else ...[
              const Center(
                child: Text('No text extracted yet. Scan a document.'),
              )
            ],
          ],
        ),
      ),
      floatingActionButton: _extractedText != null && _extractedText!.isNotEmpty
        ? Column(
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            FloatingActionButton(
              onPressed: _copyToClipboard,
              tooltip: 'Copy Text',
              heroTag: 'copy',
              child: const Icon(Icons.content_copy),
            ),
            const SizedBox(height: 16),
            FloatingActionButton(
              onPressed: _saveAsJson,
              tooltip: 'Save as JSON',
              heroTag: 'json',
              backgroundColor: Colors.green,
              child: const Icon(Icons.code),
            ),
          ],
        )
      : null,
    );
  }
}

// Helper function to check if a string contains any field name
bool containsAnyFieldName(String text, Map<String, List<String>> fieldMappings) {
  for (List<String> fieldNames in fieldMappings.values) {
    for (String fieldName in fieldNames) {
      if (text.toUpperCase().contains(fieldName.toUpperCase())) {
        return true;
      }
    }
  }
  return false;
}