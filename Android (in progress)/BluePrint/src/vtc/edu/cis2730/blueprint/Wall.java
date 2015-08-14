package vtc.edu.cis2730.blueprint;

import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.view.MotionEvent;
import android.view.View;
import android.widget.FrameLayout;

public class Wall extends FloorItem implements View.OnTouchListener
{

	public Wall(boolean horizontal, Context context, FrameLayout mainLayout)
	{
		super(context);
		_context = context;
		_horizontal = horizontal;
		_length = 50;
		_paint = new Paint();
		_paint.setColor(Color.WHITE);
		_paint.setStrokeWidth(5);
		_mainLayout = mainLayout;
		_isPaletteWall = true;
		setClickable(true);
		setOnTouchListener(this);
	}
	@Override
	public boolean onTouch(View view, MotionEvent event)
	{
		FrameLayout.LayoutParams params = (android.widget.FrameLayout.LayoutParams) view.getLayoutParams();
		switch(event.getAction())
	    {
		    case MotionEvent.ACTION_MOVE:
		    	_x2 = event.getX();
		    	_y2 = event.getY();
		        float deltax = (int)((_x - _x2) + .5);
		        float deltay = (int)((_y - _y2) + .5);
		        int oldLeftMargin = params.leftMargin;
		        int oldRightMargin = params.rightMargin;
		        int oldTopMargin= params.topMargin;
		        int oldBottomMargin = params.bottomMargin;
		        params.leftMargin = oldLeftMargin - (int) deltax;
		        params.rightMargin = oldRightMargin + (int) deltax;
		        params.topMargin = oldTopMargin - (int) deltay;
		        params.bottomMargin = oldBottomMargin + (int) deltay;
		        view.setLayoutParams(params);
		        break;
		    case MotionEvent.ACTION_UP:
		    	_x = event.getX();
		    	_y = event.getY();
		        break;
		    case MotionEvent.ACTION_DOWN:
		    	if(_isPaletteWall)
		    	{
	    			FrameLayout.LayoutParams paramsWall = new FrameLayout.LayoutParams(25, 30);

		    		if(_horizontal)
		    		{
		    			paramsWall.topMargin = 950;
		    			paramsWall.leftMargin = 150;
		    		}
		    		else
		    		{
		    			paramsWall.topMargin = 950;
		    			paramsWall.leftMargin = 50;
		    		}
		    		Wall newPalette = new Wall(_horizontal, _context, _mainLayout);
		    		_mainLayout.addView(newPalette, paramsWall);
		    		_isPaletteWall = false;
		    	}
		        _x = event.getX();
		        _y = event.getY();
		        break;
	    }
	    return false;
	}
	
	protected void onMeasure(int widthSpec, int heightSpec)
	{
		setMeasuredDimension(100, 100);
	}
	
	protected int getSuggestedMinimumWidth()
	{
		return 10;
	}
	
	protected int getSuggestedMinimumHeight()
	{
		return 10;
	}
	
	public void onDraw(Canvas canvas)
	{
		if(_horizontal)
		{
			canvas.drawLine(0, 50, 100, 50, _paint);
		}
		else
		{
			canvas.drawLine(50, 0, 50, 100, _paint);
		}
	}
	
	Paint _paint;
	int _length;
	FrameLayout _mainLayout;
	Context _context;
	boolean _isPaletteWall;
	private float _x;
	private float _x2;
	private float _y;
	private float _y2;
	boolean _horizontal;
}