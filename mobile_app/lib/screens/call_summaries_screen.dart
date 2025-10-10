import 'package:flutter/material.dart';
import '../models/call_summary.dart';
import '../services/database_service.dart';

class CallSummariesScreen extends StatefulWidget {
  const CallSummariesScreen({Key? key}) : super(key: key);

  @override
  State<CallSummariesScreen> createState() => _CallSummariesScreenState();
}

class _CallSummariesScreenState extends State<CallSummariesScreen> {
  final DatabaseService _db = DatabaseService();
  List<CallSummary> _summaries = [];
  bool _isLoading = true;
  String _searchQuery = '';
  
  @override
  void initState() {
    super.initState();
    _loadSummaries();
  }
  
  Future<void> _loadSummaries() async {
    setState(() => _isLoading = true);
    
    final summaries = _searchQuery.isEmpty
        ? await _db.getCallSummaries()
        : await _db.searchCallSummaries(_searchQuery);
    
    setState(() {
      _summaries = summaries;
      _isLoading = false;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('📞 ملخصات المكالمات'),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'ابحث في المكالمات...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value);
                _loadSummaries();
              },
            ),
          ),
          
          // Summaries List
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _summaries.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.phone_disabled, size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              'لا توجد مكالمات بعد',
                              style: TextStyle(fontSize: 18, color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: _summaries.length,
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        itemBuilder: (context, index) {
                          final summary = _summaries[index];
                          return _buildCallSummaryCard(summary);
                        },
                      ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCallSummaryCard(CallSummary summary) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showSummaryDetails(summary),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Text(
                    summary.relationshipIcon,
                    style: TextStyle(fontSize: 24),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          summary.contactName,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          summary.formattedCallTime,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: summary.wasSuccessful
                          ? Colors.green.withOpacity(0.1)
                          : Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      summary.wasSuccessful ? '✅ نجح' : '❌ فشل',
                      style: TextStyle(
                        fontSize: 12,
                        color: summary.wasSuccessful ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 12),
              
              // Summary
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.summarize, size: 16, color: Colors.blue),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        summary.summary,
                        style: TextStyle(fontSize: 14),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 8),
              
              // Footer
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.timer, size: 14, color: Colors.grey),
                      SizedBox(width: 4),
                      Text(
                        summary.formattedDuration,
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      SizedBox(width: 16),
                      Icon(Icons.speed, size: 14, color: Colors.grey),
                      SizedBox(width: 4),
                      Text(
                        '${summary.responseTime.toStringAsFixed(1)}s',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                  if (summary.topics.isNotEmpty)
                    Wrap(
                      spacing: 4,
                      children: summary.topics.take(2).map((topic) {
                        return Chip(
                          label: Text(topic),
                          labelStyle: TextStyle(fontSize: 10),
                          padding: EdgeInsets.all(4),
                          visualDensity: VisualDensity.compact,
                        );
                      }).toList(),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  void _showSummaryDetails(CallSummary summary) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        Text(
                          summary.relationshipIcon,
                          style: TextStyle(fontSize: 32),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                summary.contactName,
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                summary.contactPhone,
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                    SizedBox(height: 24),
                    
                    // Caller Message
                    _buildDetailSection(
                      '🎤 قال المتصل:',
                      summary.callerMessage,
                      Colors.blue,
                    ),
                    
                    SizedBox(height: 16),
                    
                    // AI Response
                    _buildDetailSection(
                      '🤖 رد المساعد:',
                      summary.aiResponse,
                      Colors.green,
                    ),
                    
                    SizedBox(height: 16),
                    
                    // Summary
                    _buildDetailSection(
                      '📝 الملخص:',
                      summary.summary,
                      Colors.orange,
                    ),
                    
                    SizedBox(height: 24),
                    
                    // Metadata
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        _buildMetadataChip(
                          Icons.access_time,
                          summary.formattedCallTime,
                        ),
                        _buildMetadataChip(
                          Icons.timer,
                          summary.formattedDuration,
                        ),
                        _buildMetadataChip(
                          Icons.speed,
                          '${summary.responseTime.toStringAsFixed(1)}s رد',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
  
  Widget _buildDetailSection(String title, String content, Color color) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
  
  Widget _buildMetadataChip(IconData icon, String label) {
    return Chip(
      avatar: Icon(icon, size: 16),
      label: Text(label),
      labelStyle: TextStyle(fontSize: 12),
    );
  }
}
