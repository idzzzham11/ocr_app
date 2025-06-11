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

enum DocumentType {
  gatePass,
  akuanPenerimaanBTS,
  akuanPenghantaranCPO,
  unknown
}

class DocumentData {
  final DocumentType documentType;

  // ===Common fields for all document types
  final String? deliveryNote;
  final String? lorryNumber;
  final String? trailerNumber;
  final String? weightGross;
  final String? weightTare;
  final String? weightNett;
  final String? driverName;
  
  // ===GatePass specific fields
  final String? vehicleNumber;
  final String? driverIc;
  final String? companyName;
  final String? entryDate;
  final String? entryTime;
  final String? exitDate;
  final String? exitTime;
  final String? gatepassMuda;
  final String? gatepassPeram;
  final String? gatepassMengkal;
  final String? gatepassBusuk;
  final String? gatepassPT1;
  final String? gatepassPT2;
  final String? gatepassKosong;
  final String? gatepassKotor;
  final String? gatepassLama;
  final String? gatepassDura;
  final String? gatepassPanjang;
  final String? gatepassTikus;
  //duplicate final String? trailerNumber;
  //duplicate final String? deliveryNote;
  
  // ===BTS Receipt specific fields
  final String? sellerId;
  final String? sellerName;
  final String? smallholderIc;
  final String? smallholderName;
  final String? mpobLicense;
  final String? btsDO;
  final String? btsKpaKpg;
  final String? priceTan;
  final String? btsPremium;
  final String? btsPenalti;
  final String? priceValue;
  final String? btsAvg;
  final String? btsSample;
  final String? btsBI;
  final String? btsLimit;
  final String? btsMuda;
  final String? btsPeram;
  final String? btsMengkal;
  final String? btsBusuk;
  final String? btsKosong;
  final String? btsKotor;
  final String? btsLama;
  final String? btsDura;
  final String? btsPanjang;
  final String? btsAsing;
  final String? btsMasak;
  final String? btsTikus;
  final String? btsBasah;
  final String? btsMenitis;
  final String? btsReject;
  final String? btsWeighBy;
  //duplicate final String? deliveryNote;
  //duplicate final String? lorryNumber;
  //duplicate final String? trailerNumber;
  //duplicate final String? weightGross;
  //duplicate final String? weightTare;
  //duplicate final String? weightNett;
  
  // ===CPO Delivery specific fields
  final String? deliveryTo;
  final String? salesOrder;
  final String? deliveryBil;
  //final String? deliveryNote;
  final String? contractNumber;
  final String? cpoPO;
  //final String? lorryNumber;
  
  final String? mpobNumber;
  //duplicate 
  //duplicate final 
  //duplicate final String? trailerNumber;
  //duplicate final String? weightGross;
  //duplicate final String? weightTare;
  //duplicate final String? weightNett;

  
  const DocumentData({
    required this.documentType,

    // Common fields
    this.deliveryNote,
    this.lorryNumber,
    this.trailerNumber,
    this.weightGross,
    this.weightTare,
    this.weightNett,
    this.driverName,
    
    // GatePass specific fields
    this.vehicleNumber,
    this.driverIc,
    this.companyName,
    this.entryDate,
    this.entryTime,
    this.exitDate,
    this.exitTime,
    this.gatepassMuda,
    this.gatepassPeram,
    this.gatepassMengkal,
    this.gatepassBusuk,
    this.gatepassPT1,
    this.gatepassPT2,
    this.gatepassKosong,
    this.gatepassKotor,
    this.gatepassLama,
    this.gatepassDura,
    this.gatepassPanjang,
    this.gatepassTikus,
    
    // BTS Receipt specific fields
    this.sellerId,
    this.sellerName,
    this.smallholderIc,
    this.smallholderName,
    this.mpobLicense,
    this.btsDO,
    this.btsKpaKpg,
    this.priceTan,
    this.btsPremium,
    this.btsPenalti,
    this.priceValue,
    this.btsAvg,
    this.btsSample,
    this.btsBI,
    this.btsLimit,
    this.btsMuda,
    this.btsPeram,
    this.btsMengkal,
    this.btsBusuk,
    this.btsKosong,
    this.btsKotor,
    this.btsLama,
    this.btsDura,
    this.btsPanjang,
    this.btsAsing,
    this.btsMasak,
    this.btsTikus,
    this.btsBasah,
    this.btsMenitis,
    this.btsReject,
    this.btsWeighBy,
    
    // CPO Delivery specific fields
    this.deliveryTo,
    this.salesOrder,
    this.contractNumber,
    this.deliveryBil,
    this.cpoPO,
    this.mpobNumber,
  });

  // Convert to JSON map - include all possible fields
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      // Common fields
      'documentType': documentType.name,
      'deliveryNote': deliveryNote,
      'lorryNumber': lorryNumber,
      'trailerNumber': trailerNumber,
      'weightGross': weightGross,
      'weightTare': weightTare,
      'weightNett': weightNett,
    };
    
    if (documentType == DocumentType.gatePass) {
    data.addAll({
      'vehicleNumber': vehicleNumber,
      'driverIc': driverIc,
      'driverName': driverName,
      'companyName': companyName,
      'entryDate': entryDate,
      'entryTime': entryTime,
      'exitDate': exitDate,
      'exitTime': exitTime,
    });
    } else if (documentType == DocumentType.akuanPenerimaanBTS) {
    data.addAll({
      'sellerId': sellerId,
      'sellerName': sellerName,
      'smallholderIc': smallholderIc,
      'smallholderName': smallholderName,
      'mpobLicense': mpobLicense,
      'priceTan': priceTan,
      'priceValue': priceValue,
    });
    } else if (documentType == DocumentType.akuanPenghantaranCPO) {
    data.addAll({
      'deliveryTo': deliveryTo,
      'salesOrder': salesOrder,
      'contractNumber': contractNumber,
      'deliveryBil': deliveryBil,
      'mpobNumber': mpobNumber,
    });
  }
    
    return data;
  }
  
  // Add a copyWith method for efficient updates
  DocumentData copyWith({
    DocumentType? documentType,
    // Common fields
    String? deliveryNote,
    String? lorryNumber,
    String? trailerNumber,
    String? weightGross,
    String? weightTare,
    String? weightNett,
    String? driverName,
    
    // GatePass specific fields
    String? vehicleNumber,
    String? driverIc,
    String? companyName,
    String? entryDate,
    String? entryTime,
    String? exitDate,
    String? exitTime,
    String? gatepassMuda,
    String? gatepassPeram,
    String? gatepassMengkal,
    String? gatepassBusuk,
    String? gatepassPT1,
    String? gatepassPT2,
    String? gatepassKosong,
    String? gatepassKotor,
    String? gatepassLama,
    String? gatepassDura,
    String? gatepassPanjang,
    String? gatepassTikus,
    
    // BTS Receipt specific fields
    String? sellerId,
    String? sellerName,
    String? smallholderIc,
    String? smallholderName,
    String? mpobLicense,
    String? btsDO,
    String? btsKpaKpg,
    String? priceTan,
    String? btsPremium,
    String? btsPenalti,
    String? priceValue,
    String? btsAvg,
    String? btsSample,
    String? btsBI,
    String? btsLimit,
    String? btsMuda,
    String? btsPeram,
    String? btsMengkal,
    String? btsBusuk,
    String? btsKosong,
    String? btsKotor,
    String? btsLama,
    String? btsDura,
    String? btsPanjang,
    String? btsAsing,
    String? btsMasak,
    String? btsTikus,
    String? btsBasah,
    String? btsMenitis,
    String? btsReject,
    String? btsWeighBy,
    
    // CPO Delivery specific fields
    String? deliveryTo,
    String? salesOrder,
    String? contractNumber,
    String? deliveryBil,
    String? mpobNumber,
  }) {
    return DocumentData(
      documentType: documentType ?? this.documentType,
      // Common fields
      deliveryNote: deliveryNote ?? this.deliveryNote,
      lorryNumber: lorryNumber ?? this.lorryNumber,
      trailerNumber: trailerNumber ?? this.trailerNumber,
      weightGross: weightGross ?? this.weightGross,
      weightTare: weightTare ?? this.weightTare,
      weightNett: weightNett ?? this.weightNett,
      driverName: driverName ?? this.driverName,
      
      // GatePass specific fields
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      driverIc: driverIc ?? this.driverIc,
      companyName: companyName ?? this.companyName,
      entryDate: entryDate ?? this.entryDate,
      entryTime: entryTime ?? this.entryTime,
      exitDate: exitDate ?? this.exitDate,
      exitTime: exitTime ?? this.exitTime,
      gatepassMuda: gatepassMuda ?? this.gatepassMuda,
      gatepassPeram: gatepassPeram ?? this.gatepassPeram,
      gatepassMengkal: gatepassMengkal ?? this.gatepassMengkal,
      gatepassBusuk: gatepassBusuk ?? this.gatepassBusuk,
      gatepassPT1: gatepassPT1 ?? this.gatepassPT1,
      gatepassPT2: gatepassPT2 ?? this.gatepassPT2,
      gatepassKosong: gatepassKosong ?? this.gatepassKosong,
      gatepassKotor: gatepassKotor ?? this.gatepassKotor,
      gatepassLama: gatepassLama ?? this.gatepassLama,
      gatepassDura: gatepassDura ?? this.gatepassDura,
      gatepassPanjang: gatepassPanjang ?? this.gatepassPanjang,
      gatepassTikus: gatepassTikus ?? this.gatepassTikus,
      
      // BTS Receipt specific fields
      sellerId: sellerId ?? this.sellerId,
      sellerName: sellerName ?? this.sellerName,
      smallholderIc: smallholderIc ?? this.smallholderIc,
      smallholderName: smallholderName ?? this.smallholderName,
      mpobLicense: mpobLicense ?? this.mpobLicense,
      btsDO: btsDO ?? this.btsDO,
      btsKpaKpg: btsKpaKpg ?? this.btsKpaKpg,
      priceTan: priceTan ?? this.priceTan,
      btsPremium: btsPremium ?? this.btsPremium,
      btsPenalti: btsPenalti ?? this.btsPenalti,
      priceValue: priceValue ?? this.priceValue,
      btsAvg: btsAvg ?? this.btsAvg,
      btsSample: btsSample ?? this.btsSample,
      btsBI: btsBI ?? this.btsBI,
      btsLimit: btsLimit ?? this.btsLimit,
      btsMuda: btsMuda ?? this.btsMuda,
      btsPeram: btsPeram ?? this.btsPeram,
      btsMengkal: btsMengkal ?? this.btsMengkal,
      btsBusuk: btsBusuk ?? this.btsBusuk,
      btsKosong: btsKosong ?? this.btsKosong,
      btsKotor: btsKotor ?? this.btsKotor,
      btsLama: btsLama ?? this.btsLama,
      btsDura: btsDura ?? this.btsDura,
      btsPanjang: btsPanjang ?? this.btsPanjang,
      btsAsing: btsAsing ?? this.btsAsing,
      btsMasak: btsMasak ?? this.btsMasak,
      btsTikus: btsTikus ?? this.btsTikus,
      btsBasah: btsBasah ?? this.btsBasah,
      btsMenitis: btsMenitis ?? this.btsMenitis,
      btsReject: btsReject ?? this.btsReject,
      btsWeighBy: btsWeighBy ?? this.btsWeighBy,
      
      // CPO Delivery specific fields
      deliveryTo: deliveryTo ?? this.deliveryTo,
      salesOrder: salesOrder ?? this.salesOrder,
      contractNumber: contractNumber ?? this.contractNumber,
      deliveryBil: deliveryBil ?? this.deliveryBil,
      mpobNumber: mpobNumber ?? this.mpobNumber,
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
  DocumentType _documentType = DocumentType.unknown;
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
      'NOMBOR KENDERAAN': ['NOMBOR KENDERAAN', 'NO. KENDERAAN', 'NO KENDERAAN', 'NOMBOR KENDERAAN :', 'No. Lori'],
      'K.P. PEMANDU': ['K.P. PEMANDU', 'NO. K/P', 'IC NO', 'K.P PEMANDU', 'K.P. PEMANDU :', 'T/T Pemandu'],
      'NAMA PEMANDU': ['NAMA PEMANDU', 'NAMA PEMANDU :', 'Penjual/Wakil/Pemandu'],
      'SYARIKAT': ['SYARIKAT', 'COMPANY', 'SYARIKAT :', 'Nama Penjual'],
      'NOMBOR TRAILER': ['NOMBOR TRAILER', 'NO. TRAILER', 'TRAILER', 'NOMBOR TRAILER :', 'No. Trailer'],
      'NOTA HANTARAN/ARAHAN ANGKUT': ['NOTA HANTARAN/ARAHAN ANGKUT', 'NOTA HANTARAN', 'ARAHAN ANGKUT', 'NOTA HANTARAN :', 'Nota Hantaran', 'Arahan Angkut'],
      'TARIKH MASUK': ['TARIKH MASUK', 'ENTRY DATE', 'TARIKH MASUK :', 'Tarikh Urusnaga'],
      'MASA MASUK': ['MASA MASUK', 'ENTRY TIME', 'MASA MASUK :'],
      'PENJUAL': ['PENJUAL', 'SELLER', 'PENJUAL :', 'PENJUAL:', 'Penjual'],
      'KP PENEROKA': ['KP PENEROKA', 'KP Peneroka', 'KP PENEROKA :'],
      'NAMA PENEROKA': ['NAMA PENEROKA', 'Nama Peneroka', 'NAMA PENEROKA :'],
      'NO. LESEN MPOB': ['NO. LESEN MPOB', 'No. Lesen MPOB', 'NO LESEN MPOB', 'No. DO'],
      'GROSS': ['GROSS', 'Gross', 'GROSS :'],
      'TARE': ['TARE', 'Tare', 'TARE :'],
      'NETT': ['NETT', 'Nett', 'NETT :', 'Nett.'],
      'HARGA/TAN': ['HARGA/TAN', 'Harga/Tan', 'HARGA/TAN :'],
      'JUMLAH NILAI': ['JUMLAH NILAI', 'Jumlah Nilai', 'JUMLAH NILAI :'],
      'KEPADA': ['KEPADA', 'Kepada', 'KEPADA :'],
      'SALES ORDER': ['SALES ORDER', 'Sales Order'],
      'NO KONTRAK': ['NO KONTRAK', 'No Kontrak', 'NO. KONTRAK'],
      'BIL. HANTARAN': ['BIL. HANTARAN', 'Bil. Hantaran'],
      'NO. MPOB': ['NO. MPOB', 'No. MPOB'],
      'TARIKH KELUAR': ['TARIKH KELUAR', 'TARIKH KELUAR :'],
      'MASA KELUAR': ['MASA KELUAR', 'MASA KELUAR :']
    };
  
    // Initialize all fields to empty string at once
    for (var key in keyFieldMappings.keys) {
      result[key] = '';
    }
  
    // Cache regular expressions for better performance
    final vehicleRegex = RegExp(r'W[A-Z][0-9]{3,4}[A-Z]?|[A-Z]{3}[0-9]{4}');  // Matches WA1086P, CDY6299, etc.
    final icRegex = RegExp(r'[0-9]{6}[0-9]{6}|[0-9]{12}');  // Matches Malaysian IC format like 650619086229
    final dateRegex = RegExp(r'\d{2}/\d{2}/\d{4}|\d{1,2}/\d{1,2}/\d{4}');  // More flexible date format
    final timeRegex = RegExp(r'\d{2}:\d{2}:\d{2}');
    final deliveryNoteRegex = RegExp(r'[A-Z]?[0-9]{5,8}|[0-9]{4,8}|[A-Z][0-9]{8}');  // Matches H00000242, 202117, etc.
    final trailerRegex = RegExp(r'T/[A-Z][0-9]{3,5}|[0-9]{2}[A-Z][A-Z][0-9]{4}|[A-Z]\s?[A-Z][0-9]');  // Matches T/A5018, 77WC2030, F J2
    final penjualRegex = RegExp(r'\d{4}-\d{3}-\d{2}');  // Fixed format to match 9066-001-04
    final mpobLicenseRegex = RegExp(r'[0-9]{12,15}');  // Matches 500775802000, 57413802500
    final weightRegex = RegExp(r'\d{1,3}\.\d{2}');  // Matches weights like 6.90, 41.59
    final priceRegex = RegExp(r'\d{1,3}\.\d{2}|\d{3,4}\.\d{2}');  // Matches prices like 946.44
  
    // Convert raw lines to uppercase once for better performance
     List<String> upperLines = rawLines.map((line) => line.toUpperCase()).toList();
    
    // First pass: Look for exact field:value patterns
  for (int i = 0; i < rawLines.length; i++) {
    final line = rawLines[i];
    final upperLine = upperLines[i];
    
    // Special handling for NOMBOR TRAILER that might span multiple lines
    if (upperLine.contains("NOMBOR TRAILER")) {
      // Check if value is on the same line
      if (upperLine.contains(":")) {
        final colonIndex = upperLine.indexOf(":", upperLine.indexOf("NOMBOR TRAILER"));
        if (colonIndex > 0 && colonIndex < line.length - 1) {
          final valueStr = line.substring(colonIndex + 1).trim();
          final trailerValue = valueStr.split(RegExp(r'\s+'))[0];
          if (trailerValue.isNotEmpty) {
            result['NOMBOR TRAILER'] = trailerValue.startsWith(':') ? trailerValue.substring(1) : trailerValue;
          }
        }
      } 
      // Check if value is on the next line
      else if (i + 1 < rawLines.length && rawLines[i + 1].trim().startsWith(':')) {
        final nextLine = rawLines[i + 1].trim();
        final valueStr = nextLine.startsWith(':') ? nextLine.substring(1).trim() : nextLine.trim();
        final trailerValue = valueStr.split(RegExp(r'\s+'))[0];
        if (trailerValue.isNotEmpty) {
          result['NOMBOR TRAILER'] = trailerValue;
        }
      }
    }

    if (upperLine.contains("NOTA HANTARAN") || upperLine.contains("ARAHAN ANGKUT")) {
      final searchTerm = upperLine.contains("NOTA HANTARAN") ? "NOTA HANTARAN" : "ARAHAN ANGKUT";
      final colonIndex = upperLine.indexOf(":", upperLine.indexOf(searchTerm));
      if (colonIndex > 0 && colonIndex < line.length - 1) {
        // Find the value after "NOTA HANTARAN/ARAHAN ANGKUT:"
        final valueStr = line.substring(colonIndex + 1).trim();
        // Extract just the value portion, handling potential trailing text
        final notaValue = valueStr.split(RegExp(r'\s+'))[0];
        if (notaValue.isNotEmpty && !notaValue.contains("MARAN") && !notaValue.contains("PAHANG")) {
          result['NOTA HANTARAN/ARAHAN ANGKUT'] = notaValue;
        }
      }
    }

    // Scan each line for multiple field patterns at once
    for (final field in keyFieldMappings.keys) {
      // Skip fields we've already specifically handled
      if (field == 'NOMBOR TRAILER' || field == 'NOTA HANTARAN/ARAHAN ANGKUT') {
        continue;
      }
      
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
        if (match != null && !line.contains('MPOB') && !line.contains('KP Peneroka')) {
          result['K.P. PEMANDU'] = match;
          break;
        }
      }
    }

    // Driver Name
    if (result['NAMA PEMANDU']!.isEmpty) {
      for (final line in rawLines) {
        final upperLine = line.toUpperCase();
        if ((upperLine.contains('BIN') || upperLine.contains('BINTI')) && 
            !upperLine.contains('PENEROKA') && !line.contains(':')) {
          result['NAMA PEMANDU'] = line.trim();
          break;
        }
      }
    }

    // Trailer Number
    if (result['NOMBOR TRAILER']!.isEmpty) {
      for (final line in rawLines) {
        final match = trailerRegex.stringMatch(line);
        if (match != null) {
          result['NOMBOR TRAILER'] = match;
          break;
        }
      }
    }

    // Delivery Note
    if (result['NOTA HANTARAN/ARAHAN ANGKUT']!.isEmpty) {
      for (final line in rawLines) {
        if (line.contains('Nota Hantaran') || line.contains('NOTA HANTARAN')) {
          final parts = line.split(':');
          if (parts.length > 1) {
            final notaValue = parts[1].trim();
            result['NOTA HANTARAN/ARAHAN ANGKUT'] = notaValue;
            break;
          }
        } else {
          final match = deliveryNoteRegex.stringMatch(line);
          if (match != null && !line.contains('No Pass') && !line.contains('MARAN')) {
            result['NOTA HANTARAN/ARAHAN ANGKUT'] = match;
            break;
          }
        }
      }
    }

    // Entry Date
    if (result['TARIKH MASUK']!.isEmpty) {
      for (final line in rawLines) {
        if (line.contains('Tarikh') || line.contains('TARIKH')) {
          final match = dateRegex.stringMatch(line);
          if (match != null) {
            result['TARIKH MASUK'] = match;
            break;
          }
        }
      }
    }

    // Entry Time
    if (result['MASA MASUK']!.isEmpty) {
      for (final line in rawLines) {
        if (line.contains('Masa') || line.contains('MASA')) {
          final match = timeRegex.stringMatch(line);
          if (match != null) {
            result['MASA MASUK'] = match;
            break;
          }
        }
      }
    }

    // Seller ID
    if (result['PENJUAL']!.isEmpty) {
      for (final line in rawLines) {
        final match = penjualRegex.stringMatch(line);
        if (match != null) {
          result['PENJUAL'] = match;
          break;
        } else if ((line.contains('Penjual') || line.contains('PENJUAL')) && line.contains(':')) {
          final parts = line.split(':');
          if (parts.length > 1 && parts[1].trim().isNotEmpty) {
            result['PENJUAL'] = parts[1].trim();
            break;
          }
        }
      }
    }

    // Company Name
    if (result['SYARIKAT']!.isEmpty) {
      for (final line in rawLines) {
        if ((line.contains('FELDA') || line.contains('Felda')) && 
            !line.contains('FGV') && !line.contains('(Formerly')) {
          result['SYARIKAT'] = line.trim();
          break;
        } else if (line.contains('Nama Penjual') && line.contains(':')) {
          final parts = line.split(':');
          if (parts.length > 1 && parts[1].trim().isNotEmpty) {
            result['SYARIKAT'] = parts[1].trim();
            break;
          }
        }
      }
    }

    // Exit Date
    if (result['TARIKH KELUAR']!.isEmpty) {
      for (final line in rawLines) {
        if (line.contains('TARIKH KELUAR') || line.contains('Tarikh Keluar')) {
          final parts = line.split(':');
          if (parts.length > 1 && parts[1].trim().isNotEmpty) {
            result['TARIKH KELUAR'] = parts[1].trim();
            break;
          }
        }
      }
    }

    // Exit Time
    if (result['MASA KELUAR']!.isEmpty) {
      for (final line in rawLines) {
        if (line.contains('MASA KELUAR') || line.contains('Masa Keluar')) {
          final parts = line.split(':');
          if (parts.length > 1 && parts[1].trim().isNotEmpty) {
            result['MASA KELUAR'] = parts[1].trim();
            break;
          }
        }
      }
    }

    // Smallholder IC
    if (result['KP PENEROKA']!.isEmpty) {
      for (final line in rawLines) {
        if (line.contains('KP Peneroka') || line.contains('KP PENEROKA')) {
          final parts = line.split(':');
          if (parts.length > 1) {
            result['KP PENEROKA'] = parts[1].trim();
            break;
          }
        }
      }
    }

    // Smallholder Name
    if (result['NAMA PENEROKA']!.isEmpty) {
      for (final line in rawLines) {
        if (line.contains('Nama Peneroka') || line.contains('NAMA PENEROKA')) {
          final parts = line.split(':');
          if (parts.length > 1) {
            result['NAMA PENEROKA'] = parts[1].trim();
            break;
          }
        }
      }
    }

    // MPOB License
    if (result['NO. LESEN MPOB']!.isEmpty) {
      for (final line in rawLines) {
        if (line.contains('Lesen MPOB') || line.contains('LESEN MPOB')) {
          final parts = line.split(':');
          if (parts.length > 1) {
            result['NO. LESEN MPOB'] = parts[1].trim();
            break;
          }
        } else {
          final match = mpobLicenseRegex.stringMatch(line);
          if (match != null && match.length >= 12 && !line.contains('PEMANDU')) {
            result['NO. LESEN MPOB'] = match;
            break;
          }
        }
      }
    }

    // Gross Weight
    if (result['GROSS']!.isEmpty) {
      for (final line in rawLines) {
        if (line.contains('Gross') || line.contains('GROSS')) {
          final match = weightRegex.stringMatch(line);
          if (match != null) {
            result['GROSS'] = match;
            break;
          }
        }
      }
    }

    // Tare Weight
    if (result['TARE']!.isEmpty) {
      for (final line in rawLines) {
        if (line.contains('Tare') || line.contains('TARE')) {
          final match = weightRegex.stringMatch(line);
          if (match != null) {
            result['TARE'] = match;
            break;
          }
        }
      }
    }

    // Net Weight
    if (result['NETT']!.isEmpty) {
      for (final line in rawLines) {
        if (line.contains('Nett') || line.contains('NETT')) {
          final match = weightRegex.stringMatch(line);
          if (match != null) {
            result['NETT'] = match;
            break;
          }
        }
      }
    }

    // Price Per Ton
    if (result['HARGA/TAN']!.isEmpty) {
      for (final line in rawLines) {
        if (line.contains('Harga/Tan') || line.contains('HARGA/TAN')) {
          final match = priceRegex.stringMatch(line);
          if (match != null) {
            result['HARGA/TAN'] = match;
            break;
          }
        }
      }
    }

    // Total Value
    if (result['JUMLAH NILAI']!.isEmpty) {
      for (final line in rawLines) {
        if (line.contains('Jumlah Nilai') || line.contains('JUMLAH NILAI')) {
          final match = priceRegex.stringMatch(line);
          if (match != null) {
            result['JUMLAH NILAI'] = match;
            break;
          }
        }
      }
    }

    // Delivery To
    if (result['KEPADA']!.isEmpty) {
      for (final line in rawLines) {
        if (line.contains('Kepada') || line.contains('KEPADA')) {
          final lineIndex = rawLines.indexOf(line);
          if (lineIndex < rawLines.length - 1 && 
              (rawLines[lineIndex + 1].contains('FGV') || rawLines[lineIndex + 1].contains('FELDA'))) {
            result['KEPADA'] = rawLines[lineIndex + 1].trim();
            break;
          }
        }
      }
    }

    // Sales Order
    if (result['SALES ORDER']!.isEmpty) {
      for (final line in rawLines) {
        if (line.contains('Sales Order') || line.contains('SALES ORDER')) {
          final parts = line.split(':');
          if (parts.length > 1) {
            result['SALES ORDER'] = parts[1].trim();
            break;
          }
        }
      }
    }

    // Contract Number
    if (result['NO KONTRAK']!.isEmpty) {
      for (final line in rawLines) {
        if (line.contains('No Kontrak') || line.contains('NO KONTRAK')) {
          final parts = line.split(':');
          if (parts.length > 1) {
            result['NO KONTRAK'] = parts[1].trim();
            break;
          }
        }
      }
    }

    // Process other fields and handle cases where values might be on consecutive lines
    for (int i = 0; i < rawLines.length; i++) {
      final line = rawLines[i].trim();
      
      // Look for field keys that might have values on the next line
      for (final field in keyFieldMappings.keys) {
        if (result.containsKey(field)) continue; // Skip if already found
        
        for (final pattern in keyFieldMappings[field]!) {
          if (line.toUpperCase() == pattern.toUpperCase()) {
            // Field name only on this line, check next line for value
            if (i + 1 < rawLines.length) {
              final nextLine = rawLines[i + 1].trim();
              if (nextLine.startsWith(':')) {
                result[field] = nextLine.substring(1).trim();
              } else {
                result[field] = nextLine;
              }
              break;
            }
          }
        }
      }
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

    print('==== RAW EXTRACTED TEXT ====');
    for (int i = 0; i < rawLines.length; i++) {
      print('${i + 1}: ${rawLines[i]}');
    }

    // First, detect the document type
    _documentType = _detectDocumentType(rawLines);
    
    // Then process based on the detected type
    switch (_documentType) {
      case DocumentType.gatePass:
        _processGatePassDocument(rawLines);
        break;
      case DocumentType.akuanPenerimaanBTS:
        _processAkuanPenerimaanBTSDocument(rawLines);
        break;
      case DocumentType.akuanPenghantaranCPO:
        _processAkuanPenghantaranCPODocument(rawLines);
        break;
      case DocumentType.unknown:
        // Fallback to gate pass processing as default
        _processGatePassDocument(rawLines);
        break;
    }
  }

  DocumentType _detectDocumentType(List<String> rawLines) {
    // First, check for explicit document type indicators
    for (String line in rawLines) {
      String upperLine = line.toUpperCase();
      
      if (upperLine.contains('AKUAN PENERIMAAN BTS') || 
          upperLine.contains('AKUAN PENERIMAAN')) {
        return DocumentType.akuanPenerimaanBTS;
      }
      
      if (upperLine.contains('AKUAN PENGHANTARAN CPO') || 
          upperLine.contains('PENGHANTARAN CPO')) {
        return DocumentType.akuanPenghantaranCPO;
      }
      
      if (upperLine.contains('PENERIMAAN BTS FELDA/FPSB/FTP/FASSB') &&
          (upperLine.contains('FELDA') || upperLine.contains('FPSB') || upperLine.contains('FTP') || upperLine.contains('FASSB'))) {
        return DocumentType.gatePass;
      }
    }
    
    // If no specific title is found, infer from keywords
    bool hasBTSKeywords = rawLines.any((line) => 
        line.toUpperCase().contains('BTS') || 
        line.toUpperCase().contains('BUAH TANDAN SEGAR'));
        
    bool hasCPOKeywords = rawLines.any((line) => 
        line.toUpperCase().contains('CPO') || 
        line.toUpperCase().contains('CRUDE PALM OIL'));
    
    if (hasBTSKeywords) return DocumentType.akuanPenerimaanBTS;
    if (hasCPOKeywords) return DocumentType.akuanPenghantaranCPO;
    
    // Default to gate pass if type cannot be determined
    return DocumentType.gatePass;
  }

  void _processGatePassDocument(List<String> rawLines) {
    // Extract basic document information
    String? companyName;
    List<String> locationLines = [];

    final Set<String> companyKeywords = {'FGV', 'Palm Industries'};
    final Set<String> locationKeywords = {'PUSAT', 'FELDA', 'MARAN', 'PAHANG', 'D/A'};

  for (int i = 0; i < math.min(5, rawLines.length); i++) {
    if (companyKeywords.any((keyword) => rawLines[i].contains(keyword))) {
      companyName = rawLines[i];
      break;
    }
  }

  for (String line in rawLines) {
    if (locationKeywords.any((keyword) => line.contains(keyword)) &&
        !line.contains(':') &&
        !line.contains('NOMBOR') &&
        !line.contains('HANTARAN')) {
      locationLines.add(line);
    }
  }

  Map<String, String> keyFields = extractKeyFields(rawLines);

  // Format output exactly as requested
  List<String> formattedOutput = [
    "PENERIMAAN BTS FELDA/FPSB/FTP/FASSB",
    "NOMBOR KENDERAAN: ${keyFields['NOMBOR KENDERAAN'] ?? ''}",
    "K.P. PEMANDU : ${keyFields['K.P. PEMANDU'] ?? ''}",
    "NAMA PEMANDU : ${keyFields['NAMA PEMANDU'] ?? ''}",
    "SYARIKAT : ${keyFields['SYARIKAT'] ?? ''}",
    "NOMBOR TRAILER : ${keyFields['NOMBOR TRAILER'] ?? ''}",
    "NOTA HANTARAN/ARAHAN ANGKUT : ${keyFields['NOTA HANTARAN/ARAHAN ANGKUT'] ?? ''}",
    "TARIKH MASUK : ${keyFields['TARIKH MASUK'] ?? ''}",
    "MASA MASUK : ${keyFields['MASA MASUK'] ?? ''}",
    "TARIKH KELUAR : ${keyFields['TARIKH KELUAR'] ?? ''}",
    "MASA KELUAR : ${keyFields['MASA KELUAR'] ?? ''}",
    "MUDA : ${keyFields['MUDA'] ?? ''}",
    "PERAM : ${keyFields['PERAM'] ?? ''}",
    "MENGKAL: ${keyFields['MENGKAL'] ?? ''}",
    "BUSUK : ${keyFields['BUSUK'] ?? ''}",
    "(P/T) : ${keyFields['(P/T)1'] ?? ''}",
    "(P/T) : ${keyFields['(P/T)2'] ?? ''}",
    "KOSONG : ${keyFields['KOSONG'] ?? ''}",
    "KOTOR : ${keyFields['KOTOR'] ?? ''}",
    "LAMA : ${keyFields['LAMA'] ?? ''}",
    "DURA : ${keyFields['DURA'] ?? ''}",
    "PANJANG: ${keyFields['PANJANG'] ?? ''}",
    "S/TIKUS: ${keyFields['S/TIKUS'] ?? ''}",
  ];

  // Save to document model
  _documentData = DocumentData(
    documentType: DocumentType.gatePass,
    companyName: companyName,
    vehicleNumber: keyFields['NOMBOR KENDERAAN'],
    driverIc: keyFields['K.P. PEMANDU'],
    driverName: keyFields['NAMA PEMANDU'],
    trailerNumber: keyFields['NOMBOR TRAILER'],
    deliveryNote: keyFields['NOTA HANTARAN/ARAHAN ANGKUT'],
    entryDate: keyFields['TARIKH MASUK'],
    entryTime: keyFields['MASA MASUK'],
    exitDate: keyFields['TARIKH KELUAR'],
    exitTime: keyFields['MASA KELUAR'],
    gatepassMuda: keyFields['MUDA'],
    gatepassPeram: keyFields['PERAM'],
    gatepassMengkal: keyFields['MENGKAL'],
    gatepassBusuk: keyFields['BUSUK'],
    gatepassPT1: keyFields['(P/T)1'],
    gatepassPT2: keyFields['(P/T)2'],
    gatepassKosong: keyFields['KOSONG'],
    gatepassKotor: keyFields['KOTOR'],
    gatepassLama: keyFields['LAMA'],
    gatepassDura: keyFields['DURA'],
    gatepassPanjang: keyFields['PANJANG'],
    gatepassTikus: keyFields['S/TIKUS'],
  );

  setState(() {
    _extractedText = formattedOutput.join('\n');

    _headerTextControllers = [
      TextEditingController(text: formattedOutput.first),
    ];

    _editableTextControllers = List.generate(
      formattedOutput.length - 1,
      (index) => TextEditingController(text: formattedOutput[index + 1]),
    );
  });
}


void _processAkuanPenerimaanBTSDocument(List<String> rawLines) {
  // Add debugging to see what text is being extracted
  print('==== BTS DOCUMENT RAW LINES ====');
  for (int i = 0; i < rawLines.length; i++) {
    print('${i + 1}: ${rawLines[i]}');
  }

  // Extract basic document information
  String? companyName;
  List<String> locationLines = [];

  final Set<String> companyKeywords = {'FGV', 'Palm Industries', 'FELDA'};
  final Set<String> locationKeywords = {'PUSAT', 'FELDA', 'MARAN', 'PAHANG', 'D/A'};

  for (int i = 0; i < math.min(5, rawLines.length); i++) {
    if (companyKeywords.any((keyword) => rawLines[i].contains(keyword))) {
      companyName = rawLines[i];
      break;
    }
  }

  for (String line in rawLines) {
    if (locationKeywords.any((keyword) => line.contains(keyword)) &&
        !line.contains(':') &&
        !line.contains('NOMBOR')) {
      locationLines.add(line);
    }
  }

  // Enhanced field extraction for BTS documents
  Map<String, String> keyFields = extractBTSKeyFields(rawLines);

  List<String> formattedOutput = [
    "AKUAN PENERIMAAN BTS",
    "Penjual : ${keyFields['PENJUAL'] ?? ''}",
    "Nama Penjual : ${keyFields['NAMA PENJUAL'] ?? ''}",
    "KP Peneroka : ${keyFields['KP PENEROKA'] ?? ''}",
    "Nama Peneroka : ${keyFields['NAMA PENEROKA'] ?? ''}",
    "No. Lesen MPOB : ${keyFields['NO. LESEN MPOB'] ?? ''}",
    "Nota Hantaran : ${keyFields['NOTA HANTARAN'] ?? ''}",
    "No. Lori : ${keyFields['NO. LORI'] ?? ''}",
    "No. Trailer : ${keyFields['NO. TRAILER'] ?? ''}",
    "No. DO : ${keyFields['NO. DO'] ?? ''}",
    "KPA/KPG : ${keyFields['KPA/KPG'] ?? ''}",
    "Harga/Tan : ${keyFields['HARGA/TAN'] ?? ''}",
    "Jum. Premium : ${keyFields['JUM. PREMIUM'] ?? ''}",
    "Penalti BTS Muda : ${keyFields['PENALTI BTS MUDA'] ?? ''}",
    "Jumlah Nilai : ${keyFields['JUMLAH NILAI'] ?? ''}",
    "Pur.Berat : ${keyFields['PUR.BERAT'] ?? ''}",
    "Sampel : ${keyFields['SAMPEL'] ?? ''}",
    "Hantaran BI : ${keyFields['HANTARAN BI'] ?? ''}",
    "Limit : ${keyFields['LIMIT'] ?? ''}",
    "Muda : ${keyFields['MUDA'] ?? ''}",
    "Peram : ${keyFields['PERAM'] ?? ''}",
    "Mengkal : ${keyFields['MENGKAL'] ?? ''}",
    "Busuk : ${keyFields['BUSUK'] ?? ''}",
    "Kosong : ${keyFields['KOSONG'] ?? ''}",
    "Kotor : ${keyFields['KOTOR'] ?? ''}",
    "Lama : ${keyFields['LAMA'] ?? ''}",
    "Dura : ${keyFields['DURA'] ?? ''}",
    "Panjang : ${keyFields['PANJANG'] ?? ''}",
    "B.Asing : ${keyFields['B.ASING'] ?? ''}",
    "Masak : ${keyFields['MASAK'] ?? ''}",
    "S.Tikus : ${keyFields['S.TIKUS'] ?? ''}",
    "Basah : ${keyFields['BASAH'] ?? ''}",
    "Menitis : ${keyFields['MENITIS'] ?? ''}",
    "Gross : ${keyFields['GROSS'] ?? ''}",
    "Tare : ${keyFields['TARE'] ?? ''}",
    "Reject : ${keyFields['REJECT'] ?? ''}",
    "Nett : ${keyFields['NETT'] ?? ''}",
    "Penjual/Wakil/Pemandu : ${keyFields['PENJUAL/WAKIL/PEMANDU'] ?? ''}",
    "Ditimbang Oleh : ${keyFields['DITIMBANG OLEH'] ?? ''}",
  ];

  _documentData = DocumentData(
    documentType: DocumentType.akuanPenerimaanBTS,
    companyName: companyName,
    sellerId: keyFields['PENJUAL'],
    sellerName: keyFields['NAMA PENJUAL'],
    smallholderIc: keyFields['KP PENEROKA'],
    smallholderName: keyFields['NAMA PENEROKA'],
    mpobLicense: keyFields['NO. LESEN MPOB'],
    deliveryNote: keyFields['NOTA HANTARAN'],
    lorryNumber: keyFields['NO. LORI'],
    trailerNumber: keyFields['NO. TRAILER'],
    btsDO: keyFields['NO. DO'],
    btsKpaKpg: keyFields['KPA/KPG'],
    priceTan: keyFields['HARGA/TAN'],
    btsPremium: keyFields['JUM. PREMIUM'],
    btsPenalti: keyFields['PENALTI BTS MUDA'],
    priceValue: keyFields['JUMLAH NILAI'],
    btsAvg: keyFields['PUR.BERAT'],
    btsSample: keyFields['SAMPEL'],
    btsBI: keyFields['HANTARAN BI'],
    btsLimit: keyFields['LIMIT'],
    btsMuda: keyFields['MUDA'],
    btsPeram: keyFields['PERAM'],
    btsMengkal: keyFields['MENGKAL'],
    btsBusuk: keyFields['BUSUK'],
    btsKosong: keyFields['KOSONG'],
    btsKotor: keyFields['KOTOR'],
    btsLama: keyFields['LAMA'],
    btsDura: keyFields['DURA'],
    btsPanjang: keyFields['PANJANG'],
    btsAsing: keyFields['B.ASING'],
    btsMasak: keyFields['MASAK'],
    btsTikus: keyFields['S.TIKUS'],
    btsBasah: keyFields['BASAH'],
    btsMenitis: keyFields['MENITIS'],
    weightGross: keyFields['GROSS'],
    weightTare: keyFields['TARE'],
    btsReject: keyFields['REJECT'],
    weightNett: keyFields['NETT'],
    driverName: keyFields['PENJUAL/WAKIL/PEMANDU'],
    btsWeighBy: keyFields['DITIMBANG OLEH'],
  );

  setState(() {
    _extractedText = formattedOutput.join('\n');

    _headerTextControllers = [
      TextEditingController(text: formattedOutput.first),
    ];

    _editableTextControllers = List.generate(
      formattedOutput.length - 1,
      (index) => TextEditingController(text: formattedOutput[index + 1]),
    );
  });
}

Map<String, String> extractBTSKeyFields(List<String> rawLines) {
  final result = <String, String>{};
  
  // Initialize all fields with empty strings
  final fieldNames = [
    'PENJUAL', 'NAMA PENJUAL', 'KP PENEROKA', 'NAMA PENEROKA', 'NO. LESEN MPOB',
    'NOTA HANTARAN', 'NO. LORI', 'NO. TRAILER', 'NO. DO', 'KPA/KPG', 'HARGA/TAN',
    'JUM. PREMIUM', 'PENALTI BTS MUDA', 'JUMLAH NILAI', 'PUR.BERAT', 'SAMPEL',
    'HANTARAN BI', 'LIMIT', 'MUDA', 'PERAM', 'MENGKAL', 'BUSUK', 'KOSONG',
    'KOTOR', 'LAMA', 'DURA', 'PANJANG', 'B.ASING', 'MASAK', 'S.TIKUS', 'BASAH',
    'MENITIS', 'GROSS', 'TARE', 'REJECT', 'NETT', 'PENJUAL/WAKIL/PEMANDU',
    'DITIMBANG OLEH'
  ];
  
  for (var field in fieldNames) {
    result[field] = '';
  }
  
  // Define generic patterns that will match across different documents
  final sellerIdPattern = RegExp(r'\d{4}-\d{3}-\d{2}'); // Matches pattern like 9066-001-04
  final icNumberPattern = RegExp(r'\b\d{12}\b'); // Matches 12-digit IC numbers
  final mpobLicensePattern = RegExp(r'\b\d{12}\b'); // Matches 12-digit MPOB license
  final weightPattern = RegExp(r'\b\d+\.\d{2}\b'); // Matches weights like 6.90, 3.82, etc.
  final pricePattern = RegExp(r'\b\d{3}\.\d{2}\b'); // Matches prices like 946.44
  final valuePattern = RegExp(r'\b\d+\.\d{2}\b'); // Matches values like 2782.53
  final vehiclePattern = RegExp(r'[A-Z]{2,3}\d{4}'); // Matches vehicle numbers like CDY6299
  
  // Process the document line by line
  for (int i = 0; i < rawLines.length; i++) {
    String line = rawLines[i];
    String upperLine = line.toUpperCase();
    
    // Extract seller ID
    if ((upperLine.contains("PENJUAL") || line.startsWith(":")) && 
        !upperLine.contains("NAMA") && sellerIdPattern.hasMatch(line)) {
      result['PENJUAL'] = sellerIdPattern.firstMatch(line)?.group(0) ?? '';
    }
    
    // Extract seller name - typically contains FELDA
    if (upperLine.contains("NAMA PENJUAL") || 
        (upperLine.contains("FELDA") && !upperLine.contains("INDUSTRIES") && !upperLine.contains("FGV"))) {
      if (upperLine.contains(":")) {
        final colonIndex = line.indexOf(':');
        result['NAMA PENJUAL'] = line.substring(colonIndex + 1).trim();
      } else if (upperLine.contains("FELDA")) {
        result['NAMA PENJUAL'] = line.trim();
      }
    }
    
    // Extract smallholder IC
    if (upperLine.contains("KP PENEROKA")) {
      // Check if value is on the same line
      if (upperLine.contains(":")) {
        final colonIndex = line.indexOf(':');
        result['KP PENEROKA'] = line.substring(colonIndex + 1).trim();
      }
      // Check if value is on next line
      else if (i + 1 < rawLines.length && icNumberPattern.hasMatch(rawLines[i+1])) {
        result['KP PENEROKA'] = icNumberPattern.firstMatch(rawLines[i+1])?.group(0) ?? '';
      }
    }
    else if (icNumberPattern.hasMatch(line) && !line.contains("MPOB") && 
            !upperLine.contains("LESEN") && result['KP PENEROKA']!.isEmpty) {
      result['KP PENEROKA'] = icNumberPattern.firstMatch(line)?.group(0) ?? '';
    }
    
    // Extract smallholder name - typically contains BIN or BINTI
    if (upperLine.contains("NAMA PENEROKA")) {
      // Check if value is on the same line
      if (upperLine.contains(":")) {
        final colonIndex = line.indexOf(':');
        result['NAMA PENEROKA'] = line.substring(colonIndex + 1).trim();
      }
      // Check if value is on next line
      else if (i + 1 < rawLines.length && 
              (rawLines[i+1].contains("BIN") || rawLines[i+1].contains("BINTI"))) {
        result['NAMA PENEROKA'] = rawLines[i+1].trim();
      }
    }
    else if ((line.contains("BIN") || line.contains("BINTI")) && 
              !line.contains("DITIMBANG") && result['NAMA PENEROKA']!.isEmpty) {
      result['NAMA PENEROKA'] = line.trim();
    }
    
    // Extract MPOB license
    if (upperLine.contains("LESEN MPOB")) {
      // Check if value is on the same line
      if (upperLine.contains(":")) {
        final colonIndex = line.indexOf(':');
        final value = line.substring(colonIndex + 1).trim();
        if (mpobLicensePattern.hasMatch(value)) {
          result['NO. LESEN MPOB'] = mpobLicensePattern.firstMatch(value)?.group(0) ?? '';
        } else {
          result['NO. LESEN MPOB'] = value;
        }
      }
      // Check if value is on next line
      else if (i + 1 < rawLines.length && mpobLicensePattern.hasMatch(rawLines[i+1])) {
        result['NO. LESEN MPOB'] = mpobLicensePattern.firstMatch(rawLines[i+1])?.group(0) ?? '';
      }
    }
    else if (mpobLicensePattern.hasMatch(line) && !icNumberPattern.hasMatch(line) && 
            !upperLine.contains("PENEROKA") && result['NO. LESEN MPOB']!.isEmpty) {
      result['NO. LESEN MPOB'] = mpobLicensePattern.firstMatch(line)?.group(0) ?? '';
    }
    
    // Extract average weight (Pur. Berat)
    if (upperLine.contains("PUR. BERAT") || upperLine.contains("PUR.BERAT")) {
      // Check for any number on the line
      final digitPattern = RegExp(r'\d+');
      if (digitPattern.hasMatch(line)) {
        result['PUR.BERAT'] = digitPattern.firstMatch(line)?.group(0) ?? '';
      }
      // Check next line
      else if (i + 1 < rawLines.length && digitPattern.hasMatch(rawLines[i+1])) {
        result['PUR.BERAT'] = digitPattern.firstMatch(rawLines[i+1])?.group(0) ?? '';
      }
    }
    
    // Extract sample information
    if (upperLine.contains("SAMPEL")) {
      // Extract everything after the colon
      if (line.contains(":")) {
        final colonIndex = line.indexOf(':');
        result['SAMPEL'] = line.substring(colonIndex + 1).trim();
      }
    }
    
    // Extract Mengkal value
    if (upperLine.contains("MENGKAL")) {
      // Try to extract just the number
      final digitPattern = RegExp(r'\d+');
      if (digitPattern.hasMatch(line)) {
        result['MENGKAL'] = digitPattern.firstMatch(line)?.group(0) ?? '';
      }
    }
    
    // Extract Panjang value
    if (upperLine.contains("PANJANG")) {
      // Try to extract just the number
      final digitPattern = RegExp(r'\d+');
      if (digitPattern.hasMatch(line)) {
        result['PANJANG'] = digitPattern.firstMatch(line)?.group(0) ?? '';
      }
    }
    
    // Extract delivery note
    if (upperLine.contains("NOTA HANTARAN")) {
      // Extract after colon
      if (line.contains(":")) {
        final colonIndex = line.indexOf(':');
        final value = line.substring(colonIndex + 1).trim();
        // Delivery notes usually have number patterns
        final notePattern = RegExp(r'\d{5,}');
        if (notePattern.hasMatch(value)) {
          result['NOTA HANTARAN'] = notePattern.firstMatch(value)?.group(0) ?? '';
        } else {
          result['NOTA HANTARAN'] = value;
        }
      }
    }
    
    // Extract lorry number
    if (upperLine.contains("NO. LORI") || upperLine.contains("NO LORI")) {
      // Extract after colon
      if (line.contains(":")) {
        final colonIndex = line.indexOf(':');
        result['NO. LORI'] = line.substring(colonIndex + 1).trim();
      }
      // Check next line
      else if (i + 1 < rawLines.length && vehiclePattern.hasMatch(rawLines[i+1])) {
        result['NO. LORI'] = rawLines[i+1].trim();
      }
    }
    else if (vehiclePattern.hasMatch(line) && result['NO. LORI']!.isEmpty) {
      result['NO. LORI'] = vehiclePattern.firstMatch(line)?.group(0) ?? '';
    }
    
    // Extract trailer number
    if (upperLine.contains("NO. TRAILER") || upperLine.contains("NO TRAILER")) {
      // Extract after colon
      if (line.contains(":")) {
        final colonIndex = line.indexOf(':');
        result['NO. TRAILER'] = line.substring(colonIndex + 1).trim();
      }
      // Check next line
      else if (i + 1 < rawLines.length) {
        result['NO. TRAILER'] = rawLines[i+1].trim();
      }
    }
    // Trailer numbers sometimes appear as F J2 or similar
    else if (line.contains("F J") || line.contains("FJ")) {
      result['NO. TRAILER'] = line.trim();
    }
    
    // Extract Delivery BI
    if (upperLine.contains("HANTARAN BI")) {
      // Extract after colon
      if (line.contains(":")) {
        final colonIndex = line.indexOf(':');
        result['HANTARAN BI'] = line.substring(colonIndex + 1).trim();
      }
    }
    
    // Extract KPA/KPG
    if (upperLine.contains("KPA/KPG")) {
      // Extract after colon
      if (line.contains(":")) {
        final colonIndex = line.indexOf(':');
        if (colonIndex + 1 < line.length) {
          result['KPA/KPG'] = line.substring(colonIndex + 1).trim();
        }
      }
      // Check next few lines for a pattern like xx.xx/xx.xx
      else {
        for (int j = i + 1; j < math.min(i + 5, rawLines.length); j++) {
          if (rawLines[j].contains("/") && valuePattern.hasMatch(rawLines[j])) {
            result['KPA/KPG'] = rawLines[j].trim();
            break;
          }
        }
      }
    }
    
    // Extract Price/Tan
    if (upperLine.contains("HARGA/TAN")) {
      // Extract after colon
      if (line.contains(":")) {
        final colonIndex = line.indexOf(':');
        result['HARGA/TAN'] = line.substring(colonIndex + 1).trim();
      }
      // Check next line for a price pattern
      else if (i + 1 < rawLines.length && pricePattern.hasMatch(rawLines[i+1])) {
        result['HARGA/TAN'] = pricePattern.firstMatch(rawLines[i+1])?.group(0) ?? '';
      }
    }
    else if (pricePattern.hasMatch(line) && result['HARGA/TAN']!.isEmpty && 
            !line.contains("JUMLAH") && !line.contains("NILAI")) {
      // Look for price pattern but avoid matching total values
      result['HARGA/TAN'] = pricePattern.firstMatch(line)?.group(0) ?? '';
    }
    
    // Extract Premium
    if (upperLine.contains("JUM. PREMIUM")) {
      // Extract after colon
      if (line.contains(":")) {
        final colonIndex = line.indexOf(':');
        result['JUM. PREMIUM'] = line.substring(colonIndex + 1).trim();
      }
    }
    
    // Extract BTS Muda penalty
    if (upperLine.contains("PENALTI BTS MUDA")) {
      // Extract the last number on the line
      final penaltyValue = line.substring(line.lastIndexOf(" ") + 1).trim();
      result['PENALTI BTS MUDA'] = penaltyValue;
    }
    
    // Extract Total Value
    if (upperLine.contains("JUMLAH NILAI")) {
      // Extract after colon
      if (line.contains(":")) {
        final colonIndex = line.indexOf(':');
        final value = line.substring(colonIndex + 1).trim();
        if (valuePattern.hasMatch(value)) {
          result['JUMLAH NILAI'] = valuePattern.firstMatch(value)?.group(0) ?? '';
        } else {
          result['JUMLAH NILAI'] = value;
        }
      }
    }
    
    // Extract Limit
    if (upperLine.contains("LIMIT")) {
      // Extract after colon
      if (line.contains(":")) {
        final colonIndex = line.indexOf(':');
        result['LIMIT'] = line.substring(colonIndex + 1).trim();
      }
      // Check next line
      else if (i + 1 < rawLines.length) {
        result['LIMIT'] = rawLines[i+1].trim();
      }
    }
    
    // Extract Weights (Gross, Tare, Reject, Nett)
    if (upperLine.contains("GROSS")) {
      // Look on same line
      if (weightPattern.hasMatch(line)) {
        result['GROSS'] = weightPattern.firstMatch(line)?.group(0) ?? '';
      }
      // Check next few lines
      else {
        for (int j = i + 1; j < math.min(i + 5, rawLines.length); j++) {
          if (weightPattern.hasMatch(rawLines[j])) {
            result['GROSS'] = weightPattern.firstMatch(rawLines[j])?.group(0) ?? '';
            break;
          }
        }
      }
    }
    
    if (upperLine.contains("TARE")) {
      // Look on same line
      if (weightPattern.hasMatch(line)) {
        result['TARE'] = weightPattern.firstMatch(line)?.group(0) ?? '';
      }
      // Check next few lines
      else {
        for (int j = i + 1; j < math.min(i + 5, rawLines.length); j++) {
          if (weightPattern.hasMatch(rawLines[j])) {
            result['TARE'] = weightPattern.firstMatch(rawLines[j])?.group(0) ?? '';
            break;
          }
        }
      }
    }
    
    if (upperLine.contains("REJECT")) {
      // Look on same line
      if (weightPattern.hasMatch(line)) {
        result['REJECT'] = weightPattern.firstMatch(line)?.group(0) ?? '';
      }
      // Check next few lines
      else {
        for (int j = i + 1; j < math.min(i + 5, rawLines.length); j++) {
          if (weightPattern.hasMatch(rawLines[j])) {
            result['REJECT'] = weightPattern.firstMatch(rawLines[j])?.group(0) ?? '';
            break;
          }
        }
      }
    }
    
    if (upperLine.contains("NETT") || upperLine.contains("NETT.")) {
      // Look on same line
      if (weightPattern.hasMatch(line)) {
        result['NETT'] = weightPattern.firstMatch(line)?.group(0) ?? '';
      }
      // Check next few lines
      else {
        for (int j = i + 1; j < math.min(i + 5, rawLines.length); j++) {
          if (weightPattern.hasMatch(rawLines[j])) {
            result['NETT'] = weightPattern.firstMatch(rawLines[j])?.group(0) ?? '';
            break;
          }
        }
      }
    }
    
    // Extract Driver/Agent info
    if (upperLine.contains("PENJUAL/WAKIL/PEMANDU") || upperLine.contains("PENJUAL/WAKI/PEMANDU")) {
      // Extract from the next line
      if (i + 1 < rawLines.length) {
        result['PENJUAL/WAKIL/PEMANDU'] = rawLines[i+1].trim();
      }
    }
    
    // Extract weigh operator
    if (upperLine.contains("DITIMBANG OLEH")) {
      // Extract after colon
      if (line.contains(":")) {
        final colonIndex = line.indexOf(':');
        if (colonIndex + 1 < line.length) {
          result['DITIMBANG OLEH'] = line.substring(colonIndex + 1).trim();
        }
      }
      // Check next few lines for names (typically contains BIN)
      else {
        for (int j = i + 1; j < math.min(i + 10, rawLines.length); j++) {
          if (rawLines[j].contains("BIN") && !rawLines[j].contains("PENJUAL")) {
            result['DITIMBANG OLEH'] = rawLines[j].trim();
            break;
          }
        }
      }
    }
    
    // Extract Muda (Young fruits)
    if (upperLine.contains("MUDA") && !upperLine.contains("PENALTI")) {
      // Try to extract just the number
      final digitPattern = RegExp(r'\d+');
      if (digitPattern.hasMatch(line)) {
        final matches = digitPattern.allMatches(line).toList();
        if (matches.isNotEmpty) {
          result['MUDA'] = matches.first.group(0) ?? '';
        }
      }
    }
  }
  
  // Print the extracted fields for debugging
  print('==== EXTRACTED BTS FIELDS ====');
  result.forEach((key, value) {
    if (value.isNotEmpty) {
      print('$key: $value');
    }
  });
  
  return result;
}

void _processAkuanPenghantaranCPODocument(List<String> rawLines) {
  // Add debugging to see what text is being extracted
  print('==== CPO DOCUMENT RAW LINES ====');
  for (int i = 0; i < rawLines.length; i++) {
    print('${i + 1}: ${rawLines[i]}');
  }

  // Extract key fields for CPO document
  Map<String, String> keyFields = extractCPOKeyFields(rawLines);
  
  // Create formatted output text using your specified format
  List<String> formattedOutput = [
    "AKUAN PENGHANTARAN CPO",
    "Kepada : ${keyFields['KEPADA'] ?? ''}",
    "Sales Order : ${keyFields['SALES ORDER'] ?? ''}",
    "Bil. Hantaran : ${keyFields['BIL. HANTARAN'] ?? ''}",
    "Arahan Angkut : ${keyFields['ARAHAN ANGKUT'] ?? ''}",
    "No Kontrak : ${keyFields['NO KONTRAK'] ?? ''}",
    "P.O : ${keyFields['P.O'] ?? ''}",
    "No. Lori : ${keyFields['NO. LORI'] ?? ''}",
    "No. Trailer : ${keyFields['NO. TRAILER'] ?? ''}",
    "No. MPOB : ${keyFields['NO. MPOB'] ?? ''}",
    "Suhu : ${keyFields['SUHU'] ?? ''}",
    "Dirt : ${keyFields['DIRT'] ?? ''}",
    "FFA : ${keyFields['FFA'] ?? ''}",
    "VM : ${keyFields['VM'] ?? ''}",
    "Dobi : ${keyFields['DOBI'] ?? ''}",
    "Bil. Seal : ${keyFields['BIL. SEAL'] ?? ''}",
    "No. Seal 1 : ${keyFields['NO. SEAL 1'] ?? ''}",
    "No. Seal 2 : ${keyFields['NO. SEAL 2'] ?? ''}",
    "No. Seal 3 : ${keyFields['NO. SEAL 3'] ?? ''}",
    "No. Seal 4 : ${keyFields['NO. SEAL 4'] ?? ''}",
    "No. Seal 5 : ${keyFields['NO. SEAL 5'] ?? ''}",
    "No. Seal 6 : ${keyFields['NO. SEAL 6'] ?? ''}",
    "No. Seal 7 : ${keyFields['NO. SEAL 7'] ?? ''}",
    "No. Seal 8 : ${keyFields['NO. SEAL 8'] ?? ''}",
    "No. Seal 9 : ${keyFields['NO. SEAL 9'] ?? ''}",
    "No. Seal 10 : ${keyFields['NO. SEAL 10'] ?? ''}",
    "Gross : ${keyFields['GROSS'] ?? ''}",
    "Tare : ${keyFields['TARE'] ?? ''}",
    "Nett : ${keyFields['NETT'] ?? ''}",
    "Pemandu : ${keyFields['PEMANDU'] ?? ''}",
    "Ditimbang Oleh : ${keyFields['DITIMBANG OLEH'] ?? ''}",
    "Disahkan Oleh : ${keyFields['DISAHKAN OLEH'] ?? ''}",
  ];
  
  // Create DocumentData object with the extracted information
  _documentData = DocumentData(
    documentType: DocumentType.akuanPenghantaranCPO,
    deliveryNote: keyFields['NOTA HANTARAN'],
    lorryNumber: keyFields['NO. LORI'],
    trailerNumber: keyFields['NO. TRAILER'],
    weightGross: keyFields['GROSS'],
    weightTare: keyFields['TARE'],
    weightNett: keyFields['NETT'],
    driverName: keyFields['PEMANDU'],
    
    // CPO-specific fields
    deliveryTo: keyFields['KEPADA'],
    salesOrder: keyFields['SALES ORDER'],
    contractNumber: keyFields['NO KONTRAK'],
    deliveryBil: keyFields['BIL. HANTARAN'],
    mpobNumber: keyFields['NO. MPOB']
  );

  setState(() {
    _extractedText = formattedOutput.join('\n');
    
    _headerTextControllers = [
      TextEditingController(text: formattedOutput.first),
    ];
    
    _editableTextControllers = List.generate(
      formattedOutput.length - 1,
      (index) => TextEditingController(text: formattedOutput[index + 1]),
    );
  });
}

// Revised helper function for CPO document extraction without direct value searches
Map<String, String> extractCPOKeyFields(List<String> rawLines) {
  final result = <String, String>{};
  
  // Initialize all possible fields with empty strings
  final fields = [
    'KEPADA', 'SALES ORDER', 'BIL. HANTARAN', 'ARAHAN ANGKUT',
    'NO KONTRAK', 'P.O', 'NO. LORI', 'NO. TRAILER', 'NO. MPOB',
    'SUHU', 'DIRT', 'FFA', 'VM', 'DOBI', 'BIL. SEAL',
    'NO. SEAL 1', 'NO. SEAL 2', 'NO. SEAL 3', 'NO. SEAL 4', 'NO. SEAL 5',
    'NO. SEAL 6', 'NO. SEAL 7', 'NO. SEAL 8', 'NO. SEAL 9', 'NO. SEAL 10',
    'GROSS', 'TARE', 'NETT', 'PEMANDU', 'DITIMBANG OLEH', 'DISAHKAN OLEH',
    'NOTA HANTARAN'
  ];
  
  for (var field in fields) {
    result[field] = '';
  }
  
  // Define generic regex patterns 
  final vehicleRegex = RegExp(r'[A-Z]{2,3}[0-9]{4,5}'); // Matches vehicle numbers like WXA5871
  final trailerRegex = RegExp(r'T/?W[A-Z][0-9]{3,4}'); // Matches trailer numbers like T/WC2030 or TWC2030
  final mpobRegex = RegExp(r'\b\d{12,13}\b'); // Matches MPOB license numbers
  final numberPattern = RegExp(r'\b\d+\.?\d*\b'); // Matches decimal numbers
  final sealNumberPattern = RegExp(r'\b\d{10,12}\b'); // Matches seal numbers
  
  // Search across all lines - this is more robust than relying on specific line numbers
  String entireText = rawLines.join(' ');
  
  // Step 1: First look for fields that are directly followed by values in the same line
  for (int i = 0; i < rawLines.length; i++) {
    String line = rawLines[i];
    String upperLine = line.toUpperCase().replaceAll(',', '.'); // Handle comma/period confusion in OCR
    
    // Extract "Kepada" field
    if (upperLine.contains("KEPADA") && upperLine.contains(":")) {
      final colonIndex = upperLine.indexOf(':');
      if (colonIndex >= 0 && colonIndex + 1 < upperLine.length) {
        final value = line.substring(colonIndex + 1).trim();
        if (value.isNotEmpty && !value.contains("FGV")) {
          result['KEPADA'] = value;
        } else if (i + 1 < rawLines.length) {
          // Look for company name in next line
          if (rawLines[i+1].contains("FGV") || rawLines[i+1].contains("BIOTECHNOLOGIES")) {
            result['KEPADA'] = rawLines[i+1].trim();
          }
        }
      }
    }
    
    // Extract "No Kontrak" field
    if ((upperLine.contains("NO KONTRAK") || upperLine.contains("NO. KONTRAK")) && 
        upperLine.contains(":")) {
      final colonIndex = upperLine.indexOf(':');
      if (colonIndex >= 0 && colonIndex + 1 < upperLine.length) {
        final value = line.substring(colonIndex + 1).trim();
        if (value.toUpperCase().contains("T0")) {
          result['NO KONTRAK'] = value;
        }
      }
    }
    
    // Extract "P.O" field
    if (upperLine.contains("P.O") && upperLine.contains(":")) {
      final colonIndex = upperLine.indexOf(':');
      if (colonIndex >= 0 && colonIndex + 1 < upperLine.length) {
        result['P.O'] = line.substring(colonIndex + 1).trim();
      }
    }
    
    // Extract "No. Lori" field
    if ((upperLine.contains("NO. LORI") || upperLine.contains("NO, LORI")) && 
        upperLine.contains(":")) {
      final colonIndex = upperLine.indexOf(':');
      if (colonIndex >= 0 && colonIndex + 1 < upperLine.length) {
        result['NO. LORI'] = line.substring(colonIndex + 1).trim();
      } else if (i + 1 < rawLines.length && vehicleRegex.hasMatch(rawLines[i+1])) {
        result['NO. LORI'] = vehicleRegex.firstMatch(rawLines[i+1])?.group(0) ?? '';
      }
    }
    
    // Extract "No. Trailer" field
    if ((upperLine.contains("NO. TRAILER") || upperLine.contains("NO, TRAILER")) && 
        upperLine.contains(":")) {
      final colonIndex = upperLine.indexOf(':');
      if (colonIndex >= 0 && colonIndex + 1 < upperLine.length) {
        result['NO. TRAILER'] = line.substring(colonIndex + 1).trim();
      } else if (i + 1 < rawLines.length && trailerRegex.hasMatch(rawLines[i+1])) {
        result['NO. TRAILER'] = trailerRegex.firstMatch(rawLines[i+1])?.group(0) ?? '';
      }
    }
    
    // Extract "No. MPOB" field
    if ((upperLine.contains("NO. MPOB") || upperLine.contains("NO, MPOB")) && 
        upperLine.contains(":")) {
      final colonIndex = upperLine.indexOf(':');
      if (colonIndex >= 0 && colonIndex + 1 < upperLine.length) {
        final value = line.substring(colonIndex + 1).trim();
        if (mpobRegex.hasMatch(value)) {
          result['NO. MPOB'] = mpobRegex.firstMatch(value)?.group(0) ?? '';
        } else {
          result['NO. MPOB'] = value;
        }
      } else if (i + 1 < rawLines.length && mpobRegex.hasMatch(rawLines[i+1])) {
        result['NO. MPOB'] = mpobRegex.firstMatch(rawLines[i+1])?.group(0) ?? '';
      }
    }
    
    // Extract "Nota Hantaran" field
    if (upperLine.contains("NOTA HANTARAN") && upperLine.contains(":")) {
      final colonIndex = upperLine.indexOf(':');
      if (colonIndex >= 0 && colonIndex + 1 < upperLine.length) {
        result['NOTA HANTARAN'] = line.substring(colonIndex + 1).trim();
      } else if (i + 1 < rawLines.length && rawLines[i+1].toUpperCase().contains("H")) {
        result['NOTA HANTARAN'] = rawLines[i+1].trim();
      }
    }
    
    // Extract "Suhu" field
    if (upperLine.contains("SUHU") && upperLine.contains(":")) {
      final colonIndex = upperLine.indexOf(':');
      if (colonIndex >= 0 && colonIndex + 1 < upperLine.length) {
        final value = line.substring(colonIndex + 1).trim();
        // Extract just the number
        final numberMatch = numberPattern.firstMatch(value);
        if (numberMatch != null) {
          result['SUHU'] = numberMatch.group(0) ?? '';
        } else {
          result['SUHU'] = value;
        }
      }
    }
    
    // Extract "Dirt" field
    if (upperLine.contains("DIRT") && upperLine.contains(":")) {
      final colonIndex = upperLine.indexOf(':');
      if (colonIndex >= 0 && colonIndex + 1 < upperLine.length) {
        final value = line.substring(colonIndex + 1).trim();
        // Extract just the number
        final numberMatch = numberPattern.firstMatch(value);
        if (numberMatch != null) {
          result['DIRT'] = numberMatch.group(0) ?? '';
        } else {
          result['DIRT'] = value;
        }
      }
    }
    
    // Extract "FFA" field
    if (upperLine.contains("FFA") && upperLine.contains(":")) {
      final colonIndex = upperLine.indexOf(':');
      if (colonIndex >= 0 && colonIndex + 1 < upperLine.length) {
        final value = line.substring(colonIndex + 1).trim();
        // Extract just the number
        final numberMatch = numberPattern.firstMatch(value);
        if (numberMatch != null) {
          result['FFA'] = numberMatch.group(0) ?? '';
        } else {
          result['FFA'] = value;
        }
      }
    }
    
    // Extract "VM" field
    if (upperLine.contains("VM") && upperLine.contains(":")) {
      final colonIndex = upperLine.indexOf(':');
      if (colonIndex >= 0 && colonIndex + 1 < upperLine.length) {
        final value = line.substring(colonIndex + 1).trim();
        // Extract just the number
        final numberMatch = numberPattern.firstMatch(value);
        if (numberMatch != null) {
          result['VM'] = numberMatch.group(0) ?? '';
        } else {
          result['VM'] = value;
        }
      }
    }
    
    // Extract "Dobi" field
    if (upperLine.contains("DOBI") && upperLine.contains(":")) {
      final colonIndex = upperLine.indexOf(':');
      if (colonIndex >= 0 && colonIndex + 1 < upperLine.length) {
        final value = line.substring(colonIndex + 1).trim();
        // Extract just the number
        final numberMatch = numberPattern.firstMatch(value);
        if (numberMatch != null) {
          result['DOBI'] = numberMatch.group(0) ?? '';
        } else {
          result['DOBI'] = value;
        }
      }
    }
    
    // Extract "Bil. Seal" field
    if ((upperLine.contains("BIL. SEAL") || upperLine.contains("BIL SEAL")) && 
        upperLine.contains(":")) {
      final colonIndex = upperLine.indexOf(':');
      if (colonIndex >= 0 && colonIndex + 1 < upperLine.length) {
        result['BIL. SEAL'] = line.substring(colonIndex + 1).trim();
      }
    }
    
    // Process seal number lines
    if (upperLine.contains("NO. SEAL") || upperLine.contains("NO SEAL")) {
      // Look for the patterns like "1) 000002791076"
      if (upperLine.contains("1)") || upperLine.contains(" 1 ")) {
        final sealMatch = sealNumberPattern.firstMatch(line);
        if (sealMatch != null) {
          result['NO. SEAL 1'] = sealMatch.group(0) ?? '';
        }
      } else if (upperLine.contains("2)") || upperLine.contains(" 2 ")) {
        final sealMatch = sealNumberPattern.firstMatch(line);
        if (sealMatch != null) {
          result['NO. SEAL 2'] = sealMatch.group(0) ?? '';
        }
      }
      // Extract more seal numbers if present in line
      else {
        for (int j = 1; j <= 10; j++) {
          if (upperLine.contains("$j)") || upperLine.contains(" $j ")) {
            final sealMatch = sealNumberPattern.firstMatch(line);
            if (sealMatch != null) {
              result['NO. SEAL $j'] = sealMatch.group(0) ?? '';
            }
          }
        }
      }
    }
    
    // Process weights - handle different formats
    if (upperLine.contains("GROSS")) {
      final matches = numberPattern.allMatches(upperLine.replaceAll(',', '.'));
      if (matches.isNotEmpty) {
        result['GROSS'] = matches.first.group(0) ?? '';
      }
    }
    
    if (upperLine.contains("TARE") && !upperLine.contains("TARE1")) {
      final matches = numberPattern.allMatches(upperLine.replaceAll(',', '.'));
      if (matches.isNotEmpty) {
        result['TARE'] = matches.first.group(0) ?? '';
      }
    }
    
    if (upperLine.contains("NETT")) {
      final matches = numberPattern.allMatches(upperLine.replaceAll(',', '.'));
      if (matches.isNotEmpty) {
        result['NETT'] = matches.first.group(0) ?? '';
      }
    }
  }
  
  // Step 2: Look for fields that might appear separately from their values
  
  // Find Sales Order number
  for (int i = 0; i < rawLines.length; i++) {
    if (rawLines[i].toUpperCase().contains("SALES ORDER")) {
      // Check next few lines for number
      for (int j = i + 1; j < math.min(i + 3, rawLines.length); j++) {
        if (RegExp(r'\d{7,8}').hasMatch(rawLines[j])) {
          result['SALES ORDER'] = RegExp(r'\d{7,8}').firstMatch(rawLines[j])?.group(0) ?? '';
          break;
        }
      }
    }
  }
  
  // Find Bil. Hantaran
  for (int i = 0; i < rawLines.length; i++) {
    if (rawLines[i].toUpperCase().contains("BIL. HANTARAN") || 
        rawLines[i].toUpperCase().contains("BL. HANTARAN")) {
      // Check next line
      if (i + 1 < rawLines.length && rawLines[i+1].toUpperCase().contains("H")) {
        result['BIL. HANTARAN'] = rawLines[i+1].trim();
      }
    }
  }
  
  // Find Arahan Angkut
  for (int i = 0; i < rawLines.length; i++) {
    if (rawLines[i].toUpperCase().contains("ARAHAN ANGKUT")) {
      // Check next line
      if (i + 1 < rawLines.length && rawLines[i+1].toUpperCase().contains("DO")) {
        result['ARAHAN ANGKUT'] = rawLines[i+1].trim();
      }
    }
  }
  
  // Find driver (Pemandu)
  for (int i = 0; i < rawLines.length; i++) {
    if (rawLines[i].toUpperCase().contains("PEMANDU") || 
        rawLines[i].toUpperCase().contains("T.T PEMANDU")) {
      // Look for Malaysian name with BIN
      for (int j = i + 1; j < math.min(i + 3, rawLines.length); j++) {
        if (rawLines[j].toUpperCase().contains("BIN") && 
            !rawLines[j].toUpperCase().contains("DITIMBANG") && 
            !rawLines[j].toUpperCase().contains("DISAHKAN")) {
          result['PEMANDU'] = rawLines[j].trim();
          break;
        }
      }
    }
  }
  
  // Find weighing officer (Ditimbang Oleh)
  for (int i = 0; i < rawLines.length; i++) {
    if (rawLines[i].toUpperCase().contains("DITIMBANG OLEH") || 
        rawLines[i].toUpperCase().contains("DITIMBANG OLEH;")) {
      // Look for Malaysian name with BIN
      for (int j = i + 1; j < math.min(i + 3, rawLines.length); j++) {
        if (rawLines[j].toUpperCase().contains("BIN") && 
            !rawLines[j].toUpperCase().contains("PEMANDU") && 
            !rawLines[j].toUpperCase().contains("DISAHKAN")) {
          result['DITIMBANG OLEH'] = rawLines[j].trim();
          break;
        }
      }
    }
  }
  
  // Find verification officer (Disahkan Oleh)
  for (int i = 0; i < rawLines.length; i++) {
    if (rawLines[i].toUpperCase().contains("DISAHKAN OLEH") || 
        rawLines[i].toUpperCase().contains("DISAHKAN OLEH;")) {
      // Look for Malaysian name with BIN
      for (int j = i + 1; j < math.min(i + 5, rawLines.length); j++) {
        if (rawLines[j].toUpperCase().contains("BIN") && 
            !rawLines[j].toUpperCase().contains("PEMANDU") && 
            !rawLines[j].toUpperCase().contains("DITIMBANG")) {
          result['DISAHKAN OLEH'] = rawLines[j].trim();
          break;
        }
      }
    }
  }
  
  // Step 3: Handle specific cases for this document format
  
  // Look for vehicle registration specifically (WXA5871)
  if (result['NO. LORI']!.isEmpty) {
    for (String line in rawLines) {
      final match = vehicleRegex.firstMatch(line.toUpperCase());
      if (match != null) {
        result['NO. LORI'] = match.group(0) ?? '';
        break;
      }
    }
  }
  
  // Look for trailer number specifically (T/WC2030 or TWC2030)
  if (result['NO. TRAILER']!.isEmpty) {
    for (String line in rawLines) {
      if (line.toUpperCase().contains("TWC") || line.toUpperCase().contains("T/WC")) {
        final match = trailerRegex.firstMatch(line.toUpperCase());
        if (match != null) {
          result['NO. TRAILER'] = match.group(0) ?? '';
          break;
        } else {
          // If regex fails, extract manually
          if (line.toUpperCase().contains("TWC")) {
            result['NO. TRAILER'] = "TWC" + line.substring(line.toUpperCase().indexOf("TWC") + 3, math.min(line.length, line.toUpperCase().indexOf("TWC") + 8));
          } else if (line.toUpperCase().contains("T/WC")) {
            result['NO. TRAILER'] = "T/WC" + line.substring(line.toUpperCase().indexOf("T/WC") + 4, math.min(line.length, line.toUpperCase().indexOf("T/WC") + 9));
          }
        }
      }
    }
  }
  
  // Look for MPOB number specifically
  if (result['NO. MPOB']!.isEmpty) {
    for (String line in rawLines) {
      if (line.length >= 12 && mpobRegex.hasMatch(line)) {
        result['NO. MPOB'] = mpobRegex.firstMatch(line)?.group(0) ?? '';
        break;
      }
    }
  }
  
  // Look for Nota Hantaran specifically (H00000242)
  if (result['NOTA HANTARAN']!.isEmpty) {
    for (String line in rawLines) {
      if (line.toUpperCase().contains("H0")) {
        final match = RegExp(r'H0+\d+').firstMatch(line.toUpperCase());
        if (match != null) {
          result['NOTA HANTARAN'] = match.group(0) ?? '';
          break;
        }
      }
    }
  }
  
  // Look for Nett weight specifically - try to find 41.59
  if (result['NETT']!.isEmpty) {
    for (String line in rawLines) {
      if (line.contains("41.") || line.contains("41,")) {
        final match = numberPattern.firstMatch(line.replaceAll(',', '.'));
        if (match != null) {
          result['NETT'] = match.group(0) ?? '';
          break;
        }
      }
    }
  }
  
  // Print extracted fields for debugging
  print('==== EXTRACTED CPO FIELDS ====');
  result.forEach((key, value) {
    if (value.isNotEmpty) {
      print('$key: $value');
    }
  });
  
  return result;
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
    if (_documentData == null || _editableTextControllers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No data to save')),
      );
      return;
    }

    try {
      // Start with a clean map that will follow the DocumentData structure
      Map<String, dynamic> jsonData = {};
      
      // First add document type
      jsonData['documentType'] = _documentData!.documentType.toString().split('.').last;
      
      // Create a mapping between UI field labels and DocumentData field names
      Map<String, String> fieldMappings = {
        // Common fields
        'NOTA HANTARAN': 'deliveryNote',
        'NOTA HANTARAN/ARAHAN ANGKUT': 'deliveryNote',
        'ARAHAN ANGKUT': 'deliveryNote',
        'NO. LORI': 'lorryNumber',
        'NOMBOR KENDERAAN': 'lorryNumber', 
        'NO. TRAILER': 'trailerNumber',
        'NOMBOR TRAILER': 'trailerNumber',
        'GROSS': 'weightGross',
        'TARE': 'weightTare',
        'NETT': 'weightNett',
        'NAMA PEMANDU': 'driverName',
        'PEMANDU': 'driverName',
        'PENJUAL/WAKIL/PEMANDU': 'driverName',
        
        // GatePass specific fields
        'SYARIKAT': 'companyName',
        'K.P. PEMANDU': 'driverIc',
        'TARIKH MASUK': 'entryDate',
        'MASA MASUK': 'entryTime',
        'TARIKH KELUAR': 'exitDate',
        'MASA KELUAR': 'exitTime',
        'MUDA': 'gatepassMuda',
        'PERAM': 'gatepassPeram',
        'MENGKAL': 'gatepassMengkal',
        'BUSUK': 'gatepassBusuk',
        'P/T': 'gatepassPT1',
        '(P/T)': 'gatepassPT1',
        'KOSONG': 'gatepassKosong',
        'KOTOR': 'gatepassKotor',
        'LAMA': 'gatepassLama',
        'DURA': 'gatepassDura',
        'PANJANG': 'gatepassPanjang',
        'S/TIKUS': 'gatepassTikus',
        'TIKUS': 'gatepassTikus',
        
        // BTS Receipt specific fields
        'PENJUAL': 'sellerId',
        'NAMA PENJUAL': 'sellerName',
        'KP PENEROKA': 'smallholderIc',
        'NAMA PENEROKA': 'smallholderName',
        'NO. LESEN MPOB': 'mpobLicense',
        'NO. DO': 'btsDO',
        'KPA/KPG': 'btsKpaKpg',
        'HARGA/TAN': 'priceTan',
        'JUM. PREMIUM': 'btsPremium',
        'PENALTI BTS MUDA': 'btsPenalti',
        'JUMLAH NILAI': 'priceValue',
        'PUR.BERAT': 'btsAvg',
        'SAMPEL': 'btsSample',
        'HANTARAN BI': 'btsBI',
        'LIMIT': 'btsLimit',
        'DITIMBANG OLEH': 'btsWeighBy',
        
        // CPO Delivery specific fields
        'KEPADA': 'deliveryTo',
        'SALES ORDER': 'salesOrder',
        'NO KONTRAK': 'contractNumber',
        'BIL. HANTARAN': 'deliveryBil',
        'NO. MPOB': 'mpobNumber',
      };
      
      // Extract values from UI and map to DocumentData field names
      for (int i = 0; i < _editableTextControllers.length; i++) {
        String fullText = _editableTextControllers[i].text;
        int colonIndex = fullText.indexOf(':');
        
        if (colonIndex > 0) {
          // Extract field label and value as shown in the UI
          String uiFieldLabel = fullText.substring(0, colonIndex).trim();
          String fieldValue = fullText.substring(colonIndex + 1).trim();
          
          // Skip empty values
          if (fieldValue.isEmpty) continue;
          
          // Find the corresponding DocumentData field name
          String? documentDataField;
          
          // Try to find exact match
          if (fieldMappings.containsKey(uiFieldLabel)) {
            documentDataField = fieldMappings[uiFieldLabel];
          } else {
            // Try to find partial match
            for (var key in fieldMappings.keys) {
              if (uiFieldLabel.contains(key)) {
                documentDataField = fieldMappings[key];
                break;
              }
            }
          }
          
          // Add to JSON if mapping found
          if (documentDataField != null) {
            jsonData[documentDataField] = fieldValue;
          } else {
            // If no mapping found, use the UI label as is
            String sanitizedLabel = uiFieldLabel.replaceAll(' ', '_').toLowerCase();
            jsonData[sanitizedLabel] = fieldValue;
          }
        }
      }
      
      // Add metadata
      jsonData['extractionTimestamp'] = DateTime.now().toIso8601String();
      jsonData['originalFileName'] = _fileName ?? 'unknown_file';
      
      // Create formatted JSON string
      final JsonEncoder jsonEncoder = JsonEncoder.withIndent('  ');
      final String prettyJson = jsonEncoder.convert(jsonData);

      // Print JSON for debugging
      print("==== DOCUMENT DATA JSON ====");
      print(prettyJson);

      // Get the temporary directory for file storage
      final Directory tempDirectory = await getTemporaryDirectory();
      final int currentTimestamp = DateTime.now().millisecondsSinceEpoch;
      
      // Create filename based on document type
      final String docType = _documentData!.documentType.toString().split('.').last;
      final String outputFileName = '${docType}_${currentTimestamp}.json';
      final String outputFilePath = '${tempDirectory.path}/$outputFileName';

      // Write JSON to file
      final File jsonFile = File(outputFilePath);
      await jsonFile.writeAsString(prettyJson, flush: true);

      // Share the file
      await Share.shareXFiles(
        [XFile(outputFilePath)],
        text: 'Document Data: $docType',
      );

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Document data saved as $outputFileName'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      // Handle any errors
      print("Error saving JSON: $e");
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving data: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _updateFieldValue(String fieldName, String value) {
    if (_documentData == null) return;

    // Remove any trailing whitespace and colon for better matching
    final cleanFieldName = fieldName.trim().replaceAll(':', '').toUpperCase();
    
    // Common fields across all document types
    switch (cleanFieldName) {
      case 'NOMBOR KENDERAAN':
      case 'NO. LORI':
      case 'NO LORI':
        _documentData = _documentData!.copyWith(lorryNumber: value);
        break;
      case 'K.P PEMANDU':
      case 'K.P. PEMANDU':
        _documentData = _documentData!.copyWith(driverIc: value);
        break;
      case 'NAMA PEMANDU':
      case 'PEMANDU':
      case 'PENJUAL/WAKIL/PEMANDU':
        _documentData = _documentData!.copyWith(driverName: value);
        break;
      case 'SYARIKAT':
      case 'COMPANY NAME':
      case 'NAMA PENJUAL':
        _documentData = _documentData!.copyWith(companyName: value);
        break;  
      case 'NOMBOR TRAILER':
      case 'NO. TRAILER':
      case 'NO TRAILER':
        _documentData = _documentData!.copyWith(trailerNumber: value);
        break;  
      case 'NOTA HANTARAN/ARAHAN ANGKUT':
      case 'NOTA HANTARAN':
      case 'ARAHAN ANGKUT':
        _documentData = _documentData!.copyWith(deliveryNote: value);
        break;
      case 'TARIKH MASUK':
      case 'ENTRY DATE':
      case 'TARIKH URUSNAGA':
        _documentData = _documentData!.copyWith(entryDate: value);
        break;
      case 'MASA MASUK':
      case 'ENTRY TIME':
        _documentData = _documentData!.copyWith(entryTime: value);
        break;
      case 'TARIKH KELUAR':
      case 'EXIT DATE':
        _documentData = _documentData!.copyWith(exitDate: value);
        break;
      case 'MASA KELUAR':
      case 'EXIT TIME':
        _documentData = _documentData!.copyWith(exitTime: value);
        break;
      case 'GROSS':
        _documentData = _documentData!.copyWith(weightGross: value);
        break;
      case 'TARE':
        _documentData = _documentData!.copyWith(weightTare: value);
        break;
      case 'NETT':
      case 'NETT.':
        _documentData = _documentData!.copyWith(weightNett: value);
        break;
    }
    
    // Document type specific fields
    if (_documentData!.documentType == DocumentType.gatePass) {
      switch (cleanFieldName) {
        case 'VEHICLENUMBER':
          _documentData = _documentData!.copyWith(vehicleNumber: value);
          break;
        case 'MUDA':
          _documentData = _documentData!.copyWith(gatepassMuda: value);
          break;
        case 'PERAM':
          _documentData = _documentData!.copyWith(gatepassPeram: value);
          break;
        case 'MENGKAL':
          _documentData = _documentData!.copyWith(gatepassMengkal: value);
          break;
        case 'BUSUK':
          _documentData = _documentData!.copyWith(gatepassBusuk: value);
          break;
        case '(P/T)':
        case 'P/T':
        case 'PT':
          if (_documentData!.gatepassPT1 == null || _documentData!.gatepassPT1!.isEmpty) {
            _documentData = _documentData!.copyWith(gatepassPT1: value);
          } else {
            _documentData = _documentData!.copyWith(gatepassPT2: value);
          }
          break;
        case 'KOSONG':
          _documentData = _documentData!.copyWith(gatepassKosong: value);
          break;
        case 'KOTOR':
          _documentData = _documentData!.copyWith(gatepassKotor: value);
          break;
        case 'LAMA':
          _documentData = _documentData!.copyWith(gatepassLama: value);
          break;
        case 'DURA':
          _documentData = _documentData!.copyWith(gatepassDura: value);
          break;
        case 'PANJANG':
          _documentData = _documentData!.copyWith(gatepassPanjang: value);
          break;
        case 'S/TIKUS':
        case 'TIKUS':
          _documentData = _documentData!.copyWith(gatepassTikus: value);
          break;
      }
    } 
    else if (_documentData!.documentType == DocumentType.akuanPenerimaanBTS) {
      switch (cleanFieldName) {
        case 'PENJUAL':
        case 'SELLER ID':
          _documentData = _documentData!.copyWith(sellerId: value);
          break;
        case 'NAMA PENJUAL':
        case 'SELLER NAME':
          _documentData = _documentData!.copyWith(sellerName: value);
          break;
        case 'KP PENEROKA':
          _documentData = _documentData!.copyWith(smallholderIc: value);
          break;
        case 'NAMA PENEROKA':
          _documentData = _documentData!.copyWith(smallholderName: value);
          break;
        case 'NO. LESEN MPOB':
        case 'NO LESEN MPOB':
          _documentData = _documentData!.copyWith(mpobLicense: value);
          break;
        case 'NO. DO':
        case 'DO':
          _documentData = _documentData!.copyWith(btsDO: value);
          break;
        case 'KPA/KPG':
          _documentData = _documentData!.copyWith(btsKpaKpg: value);
          break;
        case 'HARGA/TAN':
          _documentData = _documentData!.copyWith(priceTan: value);
          break;
        case 'JUM. PREMIUM':
        case 'PREMIUM':
          _documentData = _documentData!.copyWith(btsPremium: value);
          break;
        case 'PENALTI BTS MUDA':
          _documentData = _documentData!.copyWith(btsPenalti: value);
          break;
        case 'JUMLAH NILAI':
          _documentData = _documentData!.copyWith(priceValue: value);
          break;
        case 'PUR.BERAT':
        case 'PUR. BERAT':
          _documentData = _documentData!.copyWith(btsAvg: value);
          break;
        case 'SAMPEL':
          _documentData = _documentData!.copyWith(btsSample: value);
          break;
        case 'HANTARAN BI':
          _documentData = _documentData!.copyWith(btsBI: value);
          break;
        case 'LIMIT':
          _documentData = _documentData!.copyWith(btsLimit: value);
          break;
        case 'DITIMBANG OLEH':
          _documentData = _documentData!.copyWith(btsWeighBy: value);
          break;
        // Quality fields
        case 'MUDA':
          _documentData = _documentData!.copyWith(btsMuda: value);
          break;
        case 'PERAM':
          _documentData = _documentData!.copyWith(btsPeram: value);
          break;
        case 'MENGKAL':
          _documentData = _documentData!.copyWith(btsMengkal: value);
          break;
        case 'BUSUK':
          _documentData = _documentData!.copyWith(btsBusuk: value);
          break;
        case 'KOSONG':
          _documentData = _documentData!.copyWith(btsKosong: value);
          break;
        case 'KOTOR':
          _documentData = _documentData!.copyWith(btsKotor: value);
          break;
        case 'LAMA':
          _documentData = _documentData!.copyWith(btsLama: value);
          break;
        case 'DURA':
          _documentData = _documentData!.copyWith(btsDura: value);
          break;
        case 'PANJANG':
          _documentData = _documentData!.copyWith(btsPanjang: value);
          break;
        case 'B.ASING':
          _documentData = _documentData!.copyWith(btsAsing: value);
          break;
        case 'MASAK':
          _documentData = _documentData!.copyWith(btsMasak: value);
          break;
        case 'S.TIKUS':
          _documentData = _documentData!.copyWith(btsTikus: value);
          break;
        case 'BASAH':
          _documentData = _documentData!.copyWith(btsBasah: value);
          break;
        case 'MENITIS':
          _documentData = _documentData!.copyWith(btsMenitis: value);
          break;
        case 'REJECT':
          _documentData = _documentData!.copyWith(btsReject: value);
          break;
      }
    } 
    else if (_documentData!.documentType == DocumentType.akuanPenghantaranCPO) {
      switch (cleanFieldName) {
        case 'KEPADA':
        case 'TO':
          _documentData = _documentData!.copyWith(deliveryTo: value);
          break;
        case 'SALES ORDER':
          _documentData = _documentData!.copyWith(salesOrder: value);
          break;
        case 'NO KONTRAK':
        case 'NO. KONTRAK':
          _documentData = _documentData!.copyWith(contractNumber: value);
          break;
        case 'BIL. HANTARAN':
        case 'BIL HANTARAN':
          _documentData = _documentData!.copyWith(deliveryBil: value);
          break;
        case 'NO. MPOB':
        case 'NO MPOB':
          _documentData = _documentData!.copyWith(mpobNumber: value);
          break;
      }
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