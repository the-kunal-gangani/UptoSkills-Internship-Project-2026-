import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tinysteps/controllers/chat_controller.dart';
import 'package:tinysteps/core/constants/app_theme.dart';
import 'package:tinysteps/core/theme/theme_ext.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String sessionId;

  const ChatScreen({
    super.key,
    required this.sessionId,
  });

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _msgCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();

  @override
  void dispose() {
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollCtrl.hasClients) {
      _scrollCtrl.animateTo(
        _scrollCtrl.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _sendMessage() async {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty) return;

    _msgCtrl.clear();
    final ok = await ref.read(chatProvider(widget.sessionId).notifier).sendMessage(text);
    if (ok) {
      // Small delay to let the UI update, then scroll
      Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('Failed to send message'),
          backgroundColor: context.colors.danger,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(chatProvider(widget.sessionId));
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;

    // Trigger scroll to bottom on load/new messages
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    return Scaffold(
      backgroundColor: context.colors.bgLight,
      appBar: AppBar(
        title: Text('Session Chat', style: context.textStyles.heading2),
        backgroundColor: context.colors.bgLight,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => ref.read(chatProvider(widget.sessionId).notifier).fetchMessages(),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Session Active Window Warning Banner ──────────────────
          if (!state.isSessionActive)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              color: context.colors.danger.withValues(alpha: 0.12),
              child: Row(
                children: [
                  Icon(Icons.lock_rounded, color: context.colors.danger, size: 20),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      'Chat is only active during the scheduled session window (+/- 1 hour).',
                      style: context.textStyles.caption.copyWith(
                        color: context.colors.danger,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // ── Message History List ──────────────────────────────────
          Expanded(
            child: state.isLoading && state.messages.isEmpty
                ? Center(child: CircularProgressIndicator(color: context.colors.primary))
                : state.messages.isEmpty
                    ? _EmptyChat()
                    : ListView.builder(
                        controller: _scrollCtrl,
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        itemCount: state.messages.length,
                        itemBuilder: (context, i) {
                          final msg = state.messages[i];
                          final isMe = msg.senderId == currentUserId;
                          return _ChatBubble(message: msg, isMe: isMe);
                        },
                      ),
          ),

          // ── Message Input Row ─────────────────────────────────────
          Container(
            padding: EdgeInsets.only(
              left: AppSpacing.lg,
              right: AppSpacing.lg,
              top: AppSpacing.md,
              bottom: MediaQuery.of(context).padding.bottom + AppSpacing.md,
            ),
            decoration: BoxDecoration(
              color: context.colors.bgSurface,
              border: Border(
                top: BorderSide(color: context.colors.border),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _msgCtrl,
                    enabled: state.isSessionActive,
                    decoration: InputDecoration(
                      hintText: state.isSessionActive
                          ? 'Type a message...'
                          : 'Chat is locked',
                      filled: true,
                      fillColor: state.isSessionActive
                          ? context.colors.bgLight
                          : context.colors.border.withValues(alpha: 0.3),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: AppSpacing.md,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.full),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                IconButton.filled(
                  icon: const Icon(Icons.send_rounded),
                  style: IconButton.styleFrom(
                    backgroundColor: state.isSessionActive
                        ? context.colors.primary
                        : context.colors.textMuted,
                  ),
                  onPressed: state.isSessionActive ? _sendMessage : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyChat extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.forum_outlined, size: 64, color: context.colors.border),
          const SizedBox(height: AppSpacing.md),
          Text(
            'No messages yet',
            style: context.textStyles.bodyMuted,
          ),
          const SizedBox(height: 4),
          Text(
            'Send a message to start the conversation.',
            style: context.textStyles.caption,
          ),
        ],
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMe;

  const _ChatBubble({
    required this.message,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    final bubbleBg = isMe
        ? context.colors.primary
        : context.colors.border.withValues(alpha: 0.5);

    final textStyle = context.textStyles.bodyMedium.copyWith(
      color: isMe ? Colors.white : context.colors.textDark,
    );

    final roleLabel = message.senderRole.toUpperCase();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            // Sender role label (only for others)
            if (!isMe)
              Padding(
                padding: const EdgeInsets.only(left: 8, bottom: 2),
                child: Text(
                  roleLabel,
                  style: context.textStyles.caption.copyWith(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: context.colors.primary,
                  ),
                ),
              ),
            Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              decoration: BoxDecoration(
                color: bubbleBg,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(AppRadius.lg),
                  topRight: const Radius.circular(AppRadius.lg),
                  bottomLeft: Radius.circular(isMe ? AppRadius.lg : 2),
                  bottomRight: Radius.circular(isMe ? 2 : AppRadius.lg),
                ),
              ),
              child: Text(
                message.body,
                style: textStyle,
              ),
            ),
            // Timestamp
            Padding(
              padding: const EdgeInsets.only(top: 2, left: 4, right: 4),
              child: Text(
                _formatTime(message.createdAt),
                style: context.textStyles.caption.copyWith(fontSize: 10),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final hr = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    return '$hr:$min';
  }
}
