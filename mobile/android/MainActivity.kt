package com.example.sesliiletisim

import android.content.Intent
import android.os.Bundle
import android.widget.Button
import android.widget.TextView
import androidx.appcompat.app.AppCompatActivity

/**
 * Ana Aktivite
 * 
 * Uygulamanın başlangıç ekranıdır. Giriş yap ve kayıt ol butonlarını içerir.
 */
class MainActivity : AppCompatActivity() {
    
    private lateinit var welcomeLabel: TextView
    private lateinit var loginButton: Button
    private lateinit var registerButton: Button
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)
        
        // UI bileşenlerini bul
        welcomeLabel = findViewById(R.id.welcome_label)
        loginButton = findViewById(R.id.login_button)
        registerButton = findViewById(R.id.register_button)
        
        // Buton tıklama olaylarını yapılandır
        setupClickListeners()
    }
    
    private fun setupClickListeners() {
        // Giriş yap butonu
        loginButton.setOnClickListener {
            val intent = Intent(this, LoginActivity::class.java)
            startActivity(intent)
        }
        
        // Kayıt ol butonu
        registerButton.setOnClickListener {
            val intent = Intent(this, RegisterActivity::class.java)
            startActivity(intent)
        }
    }
} 