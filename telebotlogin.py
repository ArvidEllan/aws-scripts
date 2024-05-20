import logging
from telegram import Update
from telegram.ext import Updater, CommandHandler, CallbackContext

# Enable logging
logging.basicConfig(
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    level=logging.INFO
)
logger = logging.getLogger(__name__)

# Define a command handler to start the bot
def start(update: Update, context: CallbackContext) -> None:
    update.message.reply_text('Hi! I am your EC2 Login Detection Bot.')

# Define a command handler to fetch the logs
def get_logs(update: Update, context: CallbackContext) -> None:
    try:
        with open('/var/log/auth.log', 'r') as file:
            lines = file.readlines()
            log_text = ''.join(lines[-10:])  # Get last 10 lines
        update.message.reply_text(f"Last 10 log entries:\n{log_text}")
    except Exception as e:
        update.message.reply_text(f"Error reading log file: {e}")

def main() -> None:
    # Replace 'YOUR_TELEGRAM_BOT_TOKEN' with your bot's token
    updater = Updater("YOUR_TELEGRAM_BOT_TOKEN")

    dispatcher = updater.dispatcher

    # Register command handlers
    dispatcher.add_handler(CommandHandler("start", start))
    dispatcher.add_handler(CommandHandler("get_logs", get_logs))

    # Start the Bot
    updater.start_polling()
    updater.idle()

if __name__ == '__main__':
    main()

    