import android.util.Log
import com.teya.unifiedepossdk.commons.Logger

public class LoggerImpl : Logger {

    /**
     * Logs a debug message using Android's Log.d.
     * @param tag Used to identify the source of a log message.
     * @param message The message to log.
     */
    override fun logd(tag: String, message: String) {
        Log.d(tag, message)

    }

    /**
     * Logs an info message using Android's Log.i.
     * @param tag Used to identify the source of a log message.
     * @param message The message to log.
     */
    override fun logi(tag: String, message: String) {
        Log.i(tag, message)
    }

    /**
     * Logs a warning message using Android's Log.w.
     * @param tag Used to identify the source of a log message.
     * @param message The message to log.
     */
    override fun logw(tag: String, message: String) {
        Log.w(tag, message)
    }

    /**
     * Logs an error message using Android's Log.e.
     * @param tag Used to identify the source of a log message.
     * @param message The message to log.
     */
    override fun loge(tag: String, message: String) {
        Log.e(tag, message)
    }
}