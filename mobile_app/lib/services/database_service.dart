import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/api_key_model.dart';
import '../models/call_summary.dart';
import '../models/contact_context.dart';
import '../models/whatsapp_message.dart';

/// خدمة قاعدة البيانات المحلية (SQLite)
class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();
  
  Database? _database;
  
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }
  
  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'smart_assistant.db');
    
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }
  
  Future<void> _onCreate(Database db, int version) async {
    // جدول API Keys
    await db.execute('''
      CREATE TABLE api_keys (
        id TEXT PRIMARY KEY,
        apiKey TEXT NOT NULL,
        serviceType TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        totalRequests INTEGER DEFAULT 0,
        successfulRequests INTEGER DEFAULT 0,
        failedRequests INTEGER DEFAULT 0,
        currentUsagePercent REAL DEFAULT 0.0,
        lastUsedAt TEXT,
        isActive INTEGER DEFAULT 1,
        voiceId TEXT
      )
    ''');
    
    // جدول ملخصات المكالمات
    await db.execute('''
      CREATE TABLE call_summaries (
        id TEXT PRIMARY KEY,
        contactName TEXT NOT NULL,
        contactPhone TEXT NOT NULL,
        callTime TEXT NOT NULL,
        durationSeconds INTEGER NOT NULL,
        callerMessage TEXT NOT NULL,
        aiResponse TEXT NOT NULL,
        summary TEXT NOT NULL,
        contactRelationship TEXT,
        topics TEXT,
        responseTime REAL DEFAULT 0.0,
        wasSuccessful INTEGER DEFAULT 1,
        errorMessage TEXT
      )
    ''');
    
    // جدول سياق جهات الاتصال
    await db.execute('''
      CREATE TABLE contact_contexts (
        phoneNumber TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        relationship TEXT,
        recentTopics TEXT,
        conversationStyle TEXT,
        importantNotes TEXT,
        lastMessage TEXT,
        lastMessageTime TEXT,
        preferredTone TEXT
      )
    ''');
    
    // جدول رسائل WhatsApp
    await db.execute('''
      CREATE TABLE whatsapp_messages (
        id TEXT PRIMARY KEY,
        contactPhone TEXT NOT NULL,
        contactName TEXT NOT NULL,
        message TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        isSentByMe INTEGER DEFAULT 0
      )
    ''');
    
    print('✅ Database created successfully');
  }
  
  Future<void> init() async {
    await database;
  }
  
  // ==================== API Keys ====================
  
  Future<void> saveAPIKey(APIKeyModel key) async {
    final db = await database;
    await db.insert(
      'api_keys',
      key.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
  
  Future<List<APIKeyModel>> getAPIKeys(ServiceType type) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'api_keys',
      where: 'serviceType = ?',
      whereArgs: [type.toString()],
    );
    
    return maps.map((map) => APIKeyModel.fromJson(map)).toList();
  }
  
  Future<void> updateAPIKey(APIKeyModel key) async {
    final db = await database;
    await db.update(
      'api_keys',
      key.toJson(),
      where: 'id = ?',
      whereArgs: [key.id],
    );
  }
  
  Future<void> deleteAPIKey(String keyId) async {
    final db = await database;
    await db.delete(
      'api_keys',
      where: 'id = ?',
      whereArgs: [keyId],
    );
  }
  
  // ==================== Call Summaries ====================
  
  Future<void> saveCallSummary(CallSummary summary) async {
    final db = await database;
    await db.insert(
      'call_summaries',
      summary.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
  
  Future<List<CallSummary>> getCallSummaries({int limit = 50}) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'call_summaries',
      orderBy: 'callTime DESC',
      limit: limit,
    );
    
    return maps.map((map) => CallSummary.fromJson(map)).toList();
  }
  
  Future<List<CallSummary>> searchCallSummaries(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'call_summaries',
      where: 'contactName LIKE ? OR callerMessage LIKE ? OR aiResponse LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%'],
      orderBy: 'callTime DESC',
    );
    
    return maps.map((map) => CallSummary.fromJson(map)).toList();
  }
  
  // ==================== Contact Contexts ====================
  
  Future<void> saveContactContext(ContactContext context) async {
    final db = await database;
    await db.insert(
      'contact_contexts',
      context.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
  
  Future<ContactContext?> getContactContext(String phoneNumber) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'contact_contexts',
      where: 'phoneNumber = ?',
      whereArgs: [phoneNumber],
    );
    
    if (maps.isEmpty) return null;
    return ContactContext.fromJson(maps.first);
  }
  
  // ==================== WhatsApp Messages ====================
  
  Future<void> saveWhatsAppMessage(WhatsAppMessage message) async {
    final db = await database;
    await db.insert(
      'whatsapp_messages',
      message.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
  
  Future<List<WhatsAppMessage>> getWhatsAppMessages(
    String contactPhone, {
    int limit = 50,
  }) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'whatsapp_messages',
      where: 'contactPhone = ?',
      whereArgs: [contactPhone],
      orderBy: 'timestamp DESC',
      limit: limit,
    );
    
    return maps.map((map) => WhatsAppMessage.fromJson(map)).toList();
  }
  
  // ==================== Statistics ====================
  
  Future<Map<String, dynamic>> getStatistics() async {
    final db = await database;
    
    // إجمالي المكالمات
    final totalCalls = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM call_summaries'),
    ) ?? 0;
    
    // المكالمات الناجحة
    final successfulCalls = Sqflite.firstIntValue(
      await db.rawQuery(
        'SELECT COUNT(*) FROM call_summaries WHERE wasSuccessful = 1',
      ),
    ) ?? 0;
    
    // متوسط وقت الرد
    final avgResponseTime = (await db.rawQuery(
      'SELECT AVG(responseTime) as avg FROM call_summaries',
    )).first['avg'] ?? 0.0;
    
    // إجمالي جهات الاتصال
    final totalContacts = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM contact_contexts'),
    ) ?? 0;
    
    return {
      'totalCalls': totalCalls,
      'successfulCalls': successfulCalls,
      'successRate': totalCalls > 0 
          ? (successfulCalls / totalCalls * 100) 
          : 100.0,
      'averageResponseTime': avgResponseTime,
      'totalContacts': totalContacts,
    };
  }
}
