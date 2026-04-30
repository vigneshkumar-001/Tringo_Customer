import android.content.Context
import android.telephony.TelephonyManager
import androidx.core.content.ContextCompat
import com.wsc.sim_card_info.SimCardInfoPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import org.junit.jupiter.api.Assertions.assertEquals
import org.mockito.Mock
import kotlin.test.Test
import org.mockito.Mockito
import org.mockito.Mockito.`when`
import org.mockito.MockitoAnnotations
import kotlin.test.BeforeTest

import android.os.Process

internal class SimCardInfoPluginTest {
    @Mock
    private lateinit var mockTelephonyManager: TelephonyManager

    @Mock
    private lateinit var context: Context

    @BeforeTest
    fun setup() {
        val mockProcess = Mockito.mock(Process::class.java)
        MockitoAnnotations.openMocks(this)
        `when`(context.getSystemService(Context.TELEPHONY_SERVICE)).thenReturn(mockTelephonyManager)
//    Mockito.`when`(mockProcess.myPpid()).thenReturn(1234)
    }

  @Test
  fun testGetSimInfo() {
      // Mock the required permissions
      `when`(
          ContextCompat.checkSelfPermission(
              context,
              android.Manifest.permission.READ_PHONE_STATE
          )
      ).thenReturn(android.content.pm.PackageManager.PERMISSION_GRANTED)

      // Mock TelephonyManager behavior
      `when`(mockTelephonyManager.networkOperatorName).thenReturn("Mocked Carrier")
      `when`(mockTelephonyManager.simOperatorName).thenReturn("Mocked Display Name")
      `when`(mockTelephonyManager.simSerialNumber).thenReturn("Mocked Slot Index")
      `when`(mockTelephonyManager.line1Number).thenReturn("Mocked Number")
      `when`(mockTelephonyManager.simCountryIso).thenReturn("Mocked Country ISO")

      // Create an instance of the class containing the method
      val yourClassInstance = SimCardInfoPlugin()

      // Call the method under test
      val result = yourClassInstance.getSimInfo()

      // Verify the result based on your expectations
      assertEquals(
          "[{\"carrierName\":\"Mocked Carrier\",\"displayName\":\"Mocked Display Name\"," +
                  "\"slotIndex\":\"Mocked Slot Index\",\"number\":\"Mocked Number\"," +
                  "\"countryIso\":\"Mocked Country ISO\",\"countryPhonePrefix\":\"Mocked Country ISO\"}]",
          result
      )
  }
}